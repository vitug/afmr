{************************************************************}
{                                                            }
{                 Модуль sp_unit                             }
{       Copyright (c) 2000-2016                              }
{               RSMUV                                        }
{                                                            }
{  Developer: Vasiliy Tugarinov                              }
{  Modification:  december 2016                              }
{                                                            }
{************************************************************}
//Antiferromagnetic resonance spectrometer controller
Unit sp_unit;

Interface
//{$DEFINE debug}

uses
  Basic, Charger, tempr_s, Spectrm, V_meter, Adc_Base, CommonTypes,
  FileParams, FileRelis, Lcard,
  SysUtils, Dialogs, Windows, Classes;

const
  FileNameLength = 4;

type
  // Поток для более позднего разряда, чтобы плата успела выполнить аппаратную подготовку перед стартом
  TChargerThread = class(TThread)
  private
    FCharger: TCharger;
  public
    constructor Create(Charger: TCharger);
    procedure Execute; override;
  end;

  PTSpectrometer = ^TSpectrometer;    //управляет записью спектра, хранением и записью спектров
  TSpectrometer = class
  private
    FFileParam: TFileParam;           // ссылка на ini файл с параметрами
    FAdcSpectrMeassure: TAdcSpectr;   // АЦП измерения (сигнал + поле)
    FAdcLevelSignal: TAdcLevelSignal; // АЦП уровня сигнала
    FZeroLevel: integer;              // Уровень нуля карты
    FCharger: TCharger;               // заряд-разряд
    FChargerThread: TChargerThread;   // поток для разряда
    FSb: TSpectrumBase;               // база спектров
    FPulseGenerator: TPulseGenerator; // обработка импульса
    FTempSensor: TemperatureSensor;   // датчик температуры
    FVoltmeter: TVoltmeter;           // Вольтметр
    FFileCounter: word;               // Счетчик файлов спектров
    FDescription: TSpectrDescription; //Описание спектра
    FisBusy: Boolean;                 // занято
    FFiles: TFiles;                   // Работа с файлами
    FSaveDebugADCData: boolean;       // флаг записи отладочных данных с АЦП (поле и сигнал)
    FFullyCharge: boolean;            // Флаг окончания зарядки батарии в потоке при использовании автостарта
    FAutoGaugeScale: byte;            // Мастаб в "%" шкалы прибора, от величины сигнала (для быстрой подстройки под выходной уровень сигнала индикатора)
  protected
    procedure SaveCurrentData(FrontBack_: TFrontBack);        // запись данных
    procedure SaveCurrentPulse;                               // запись импульса
    procedure SaveCurrentSignal;                              // запись сигнала
  public
    constructor Create(Param: TFileParam);  // конструктор класса
    constructor CreateWithoutCamacAndLcard;
    function GetTemperature: real;    // возвращает температуру
    function GetChargeVoltage: real;  // возвращает напряжение заряда
    function GetThermopareVoltage: double; //возвращает напряжение на термопаре в мкВ
    function GetMaxField(volt: Real): real; // возвращает макс поле от заряда
    function Debug: boolean;          // Проверяет режим (отладка, нормально)
    function UnderThreshold: boolean; // проверяет температуру ниже уст. порога
    function ReadyADC: Boolean;       // проверяет готовность АЦП к работе
    function NextSpectrum: Boolean;   // След. спектр из базы
    function PrevSpectrum: Boolean;   // Пред. спектр из базы
    procedure StartRecord;            //запись спектра
    procedure Charge;                 // Заряд
    procedure UnCharge;               // Разряд
    procedure AutoCharge;             // Заряд который выставляет флаг о полной зарядке(для автостарта)
    function ReadAdcData(FileName: string): TADC_DATA;    // Чтение данных АЦП из файла для отладки
    procedure CreateModules;          // Создание модулей КАМАК и Лкарда
    procedure InitE2010Only;          // Инициализация только платы Е2010 в случае сбоя ее работы
    procedure SetTempZeroCompensation(ZeroCorrection:double);

    property SB: TSpectrumBase read FSb write FSb;   // База спектров
    property AdcSpectr: TAdcSpectr read FAdcSpectrMeassure write FAdcSpectrMeassure; // АЦП spectra
    property AdcLevel: TAdcLevelSignal read FAdcLevelSignal write FAdcLevelSignal;   //АЦП уровня сигнала
    property PulseGenerator: TPulseGenerator read FPulseGenerator write FPulseGenerator;
    property isBusy: Boolean read FisBusy write FisBusy;                        // Занято
    property TempSensor: TemperatureSensor read FTempSensor write FTempSensor; // Температура
    property IniFileParam: TFileParam read FFileParam;                      // ини файл с параметрами
    property Files: TFiles read FFiles;                                     // управление каталогами
    property ZeroLevel: integer read FZeroLevel write FZeroLevel;           // Уровень нуля АЦП
    property SaveDebugADCData: Boolean read FSaveDebugADCData write FSaveDebugADCData; //Запись отлад. данных
    property FullyCharge: boolean read FFullyCharge;
    property Description: TSpectrDescription read FDescription write FDescription;
    property AutoGaugeScale: byte read FAutoGaugeScale write FAutoGaugeScale;
    property ZeroCompensationTempSensor:double write SetTempZeroCompensation;

  end;

  // Поток для автостарта, в нем выплняеися цикл сравнения напряжений, чтобы не вызывать подвисание программы
  TChargerStartThread = class(TThread)
  private
    FCharger: TCharger;
    FSpectrometer: TSpectrometer;
  public
    constructor Create(Charger: TCharger; Spectrometer: TSpectrometer);
    procedure Execute; override;
  end;

implementation

uses ConvUtils;

//==================================================

constructor TSpectrometer.Create(Param: TFileParam);
var
  LastChanges: TLastChangesExperiment;
begin
  //Зарядка бат. для автостарта
  FFullyCharge := false;

  FFiles := TFiles.CreateDirectory;             // Подготавливает каталог файлов
  FFileParam := Param;                 // Ссылка файла параметров
  FPulseGenerator := TPulseGenerator.Create; // Обработка импульса
  CreateModules;                       // Создает объекты устройств и др.

  // Читаем из ини файла параметры о настройках АЦП
  FAdcSpectrMeassure.ChannelField := FFileParam.GetParamChField;
  FAdcSpectrMeassure.ChannelSignal := FFileParam.GetParamChSignal;
  FAdcSpectrMeassure.Frequency := FFileParam.GetAdcRate;
  FAdcSpectrMeassure.Duration := FFileParam.GetDurationSpectr;

  FAdcLevelSignal.ChannelLevel := FFileParam.GetParamChLevel;
  FAdcLevelSignal.Frequency := FFileParam.GetRateAdcLevel;
  FAdcLevelSignal.Duration := FFileParam.GetDurationLevel;

  // Передадим в PulseGenerator начальные параметры цепи и калибровочные коэф. и значение макс. ошибки из файла
  FPulseGenerator.RiseUpCoefSet := FFileParam.GetRiseUpCoefSet;
  FPulseGenerator.DownCoefSet := FFileParam.GetDownCoefSet;
  FPulseGenerator.BeginParamCircuit := FFileParam.GetParamCircuit;
  FPulseGenerator.MaxErrorFit := FFileParam.GetMaxErrorFit;

  // Читаем и устанавливаем флаг записи отладочных данных с АЦП
  FSaveDebugADCData := FFileParam.GetFlagSaveDebugADCData;
  //Сразу проверим каталог, если его нет то создадим
  if FSaveDebugADCData then
    FFiles.CreateSubDirDebug;

  //Заполним свойства эксперимента
  //Прочитав последние использованные значения из файла
  LastChanges := FFileParam.GetLastChangesExperiment;
  with FDescription do
  begin
    Crystal := LastChanges.Crystal;
    Generator := LastChanges.Generator;
    Section := LastChanges.Section;
    Thermopair := LastChanges.Thermopair;
    Orientation := LastChanges.Orientation;
    Comment := LastChanges.Comment;
  end;

  //Читаем значение шкалы индикатора для автоподстройки из файла
  FAutoGaugeScale := FFileParam.GetAutoScalePercent;

  FZeroLevel := 0;                    // Уровень нуля карты
  FFileCounter := 0;
  FisBusy := false;

  // Подготовим плату для измерения уровня
  if ReadyADC then
    FAdcLevelSignal.Prepare;

  FTempSensor.Unorm:=FFileParam.GetLastThermoCoupleRealControlPointU;
  FTempSensor.ControlPoint:=FFileParam.GetLastThermoCoupleControlPointU;

end;

//--------------------------------------------------

constructor TSpectrometer.CreateWithoutCamacAndLcard;
begin
//  New(FSB);
  FSB := TSpectrumBase.Init;
end;

//--------------------------------------------------

procedure TSpectrometer.StartRecord;
var
  SpectrFront: TSpectrum;
  SpectrBack:  TSpectrum;
  TempSignal: TADC_DATA;
{$if Defined(debug)}
  Field, Signal: TADC_DATA;
{$ifend}
begin
  FisBusy := true;
  FFullyCharge := false; //сбросим флаг зарядки автостарта

  //Обновим данные в описании спектра
  FDescription.Temperature := GetTemperature;
  FDescription.ChargeVoltage := GetChargeVoltage;
  FDescription.ThermopairVoltage := GetThermopareVoltage;

{$if Defined(debug)}
  // имитируем старт, читая данные АЦП из файлов
  Field := ReadAdcData('First_00000001.dat');
  Signal := ReadAdcData('Second_00000001.dat');
{$else}
  if not FAdcSpectrMeassure.Ready then
    exit;

  //Поток для разряда (разряжаем чуть позже старта, чтобы АЦП успел проинициализироваться перед сбором)
  FChargerThread := nil;
  FChargerThread := TChargerThread.Create(FCharger);
  FChargerThread.Resume;

  //Подготовим плату перед стартом
  FAdcSpectrMeassure.Prepare;

  // Старт АПЦ
  FAdcSpectrMeassure.Start;
{$ifend}

{$if Defined(debug)}
  //Обрабатываем импульс поля
  FPulseGenerator.Fit(Field, FDescription.ChargeVoltage);
  //Обрабатываем сигнал
  //TempSignal := FPulseGenerator.RecalcSignal(Signal);
  TempSignal := FPulseGenerator.RecalcSignalFull(Signal);
{$else}
  //Обрабатываем импульс поля
  FPulseGenerator.Fit(FAdcSpectrMeassure.GetDataOfChannel(FAdcSpectrMeassure.ChannelField.Number), FDescription.ChargeVoltage);
  //Обрабатываем сигнал
  //TempSignal := FPulseGenerator.RecalcSignal(FAdcSpectrMeassure.GetDataOfChannel(FAdcSpectrMeassure.ChannelSignal.Number));
  TempSignal := FPulseGenerator.RecalcSignalFull(FAdcSpectrMeassure.GetDataOfChannel(FAdcSpectrMeassure.ChannelSignal.Number));
{$ifend}
  // передняя часть импульса
  FDescription.FrontBack := fbFront; //указываем явно какой фронт
  SpectrFront := TSpectrum.InitEstimateFieldFit(TempSignal, FPulseGenerator, FDescription);

  // задняя часть импульса
  FDescription.FrontBack := fbBack; //указываем явно какой фронт
  SpectrBack := TSpectrum.InitEstimateFieldFit(TempSignal, FPulseGenerator, FDescription);

  //Подготавливаем АЦП для измерения уровня сигнала
  if FAdcLevelSignal.Ready then
    FAdcLevelSignal.Prepare;

  //Увеличиваем счетчик файлов
  inc(FFileCounter);

  //Добавляем в базу задний фронт и записываем его
  SpectrBack.FileNumber := FFileCounter;
  FSb.Add(SpectrBack);
  SaveCurrentData(fbBack);

  //Добавляем в базу передний фронт и записываем его
  SpectrFront.FileNumber := FFileCounter;
  FSb.Add(SpectrFront);
  SaveCurrentData(fbFront);

  //Запись отладочных данных с АЦП
  if FSaveDebugADCData then
  begin
    SaveCurrentPulse;
    SaveCurrentSignal;
  end;

  FisBusy := false;
end;

//--------------------------------------------------

function TSpectrometer.GetTemperature:real;
var
  T: double;
begin
{$if Defined(debug)}
  T := 273;
{$else}
  T := TempSensor.GetTemp;
{$ifend}
  Result := T;
end;

//--------------------------------------------------

function TSpectrometer.GetChargeVoltage:real;
var
 Volt: real;
begin
  FVoltmeter.Measure;
{$if Defined(debug)}
  Volt := 220;
{$else}
  Volt := FVoltMeter.U;
{$ifend}
  Result := Volt;
end;

//--------------------------------------------------

function TSpectrometer.GetThermopareVoltage: double;
var
  Volt: double;
begin
{$if Defined(debug)}
  Volt := 0;
{$else}
  Volt := TempSensor.U * 1E6;
{$ifend}
  Result := Volt;
end;

//--------------------------------------------------

function TSpectrometer.GetMaxField(volt: Real): real;
begin
  if Volt > 0 then
    Result := FPulseGenerator.GetField(6E-3 ,volt)
  else
    Result := 0;
end;

//--------------------------------------------------

procedure TSpectrometer.SaveCurrentData(FrontBack_: TFrontBack);
var
  FileNameWhithZero: String;
  TempPath: String;
begin
  TempPath := '';
  FileNameWhithZero := FFiles.MakeFileNameWithZeros(FFileCounter);

  if FrontBack_ = fbBack then
    TempPath := FFiles.SpectrsRoot + 'Back\'
  else
    TempPath := FFiles.SpectrsRoot + 'Front\';

  if not DirectoryExists(TempPath) then
    ForceDirectories(TempPath);

  FSb.SaveData(TempPath + FileNameWhithZero + '.dat');
end;

//--------------------------------------------------

procedure TSpectrometer.SaveCurrentPulse;
var
  FileNameWhithZero: String;
  TempPath: String;
begin
  TempPath := '';
//  FSb.GetCurrent.FileNumber := FFileCounter;
  FileNameWhithZero := FFiles.MakeFileNameWithZeros(FFileCounter);

  TempPath := FFiles.DebugTimeStampDir + 'Pulse\';

  if not DirectoryExists(TempPath) then
    ForceDirectories(TempPath);

  FSb.SavePulse(TempPath + FileNameWhithZero + '.dat');
end;

//--------------------------------------------------

procedure TSpectrometer.SaveCurrentSignal;
var
  FileNameWhithZero: String;
  TempPath: String;
begin
  TempPath := '';
  FileNameWhithZero := FFiles.MakeFileNameWithZeros(FFileCounter);

  TempPath := FFiles.DebugTimeStampDir + 'Signal\';

  if not DirectoryExists(TempPath) then
    ForceDirectories(TempPath);

  FSb.SaveSignal(TempPath + FileNameWhithZero + '.dat');
end;

//--------------------------------------------------

procedure TSpectrometer.Charge;
begin
  FCharger.Charge;
end;

//--------------------------------------------------

procedure TSpectrometer.UnCharge;
begin
  FCharger.Uncharge;
end;

//--------------------------------------------------

function TSpectrometer.ReadAdcData(FileName: string): TADC_DATA;
var
  i, LinesFile: longint;
  F: Text;
  FileStr: String[100];
  DataStr: TFileADC_Data;
  AdcData: TADC_DATA;
begin
  AssignFile(F, FFiles.DebugRoot + 'ADC_Data\' + FileName);
{$I-}
  Reset(F);
{$I+}
  if IOResult <> 0 then
  begin
    MessageBox(HWND(nil), 'Error read data', 'Debug error', MB_OK + MB_ICONERROR);
    exit;
  end;

  //Узнаем кол-во строк в файле (Размер буфера)
  LinesFile := 0;
  while not SeekEof(F) do
  begin
    Readln(F);
    inc(LinesFile);
  end;

  //Узнаем кол-во строк с даннымми в файле (отбросим комментарий)
  LinesFile := LinesFile - FileDebugComment;

  //-----------Разбираем данные---------------
  Reset(F);
  //Пропускаем комментарии
  for i := 0 to FileDebugComment - 1 do
  begin
    Readln(F);
  end;

  //Читаем числа
  SetLength(AdcData, LinesFile); //распределили массив для данных из файла

  i := 0;
  while not SeekEof(F) do
  begin
    Readln(F, FileStr);
    DataStr := FFiles.GetWords(FileStr);
    inc(i);

    AdcData[i - 1].time := ConvertStringInFloat(DataStr[0]);
    AdcData[i - 1].quantization_step := StrToInt(DataStr[1]);
    AdcData[i - 1].voltage := ConvertStringInFloat(DataStr[2]);
  end;
  CloseFile(F);
  Result := AdcData;
end;

//--------------------------------------------------

procedure TSpectrometer.AutoCharge;
var
  ChargerStart: TChargerStartThread;
begin
  ChargerStart := TChargerStartThread.Create(FCharger, Self);
  ChargerStart.Resume;
end;

//--------------------------------------------------

function TSpectrometer.NextSpectrum: Boolean;
begin
  Result := True;
  if FSb <> nil then
    if not FSb.Up then
      Result := False;
end;

//--------------------------------------------------

function TSpectrometer.PrevSpectrum: Boolean;
begin
  Result := True;
  if (FSb <> nil) then
    if not FSb.Down then
      Result := False;
end;

//--------------------------------------------------

procedure TSpectrometer.CreateModules;
var
  E2010: TPlata;
begin
  E2010 := TPlata.PlataCreate;
  FAdcSpectrMeassure := TAdcSpectr.Create(E2010);          // АЦП измерения (сигнал + поле)
  FAdcLevelSignal := TAdcLevelSignal.Create(E2010);        // АЦП уровня сигнала
  FCharger := TCharger.Init(E2010);                        // заряд-разряд
  FSb := TSpectrumBase.Init;                        // база спектров
  FTempSensor := TemperatureSensor.Init;            // датчик температуры
  FVoltmeter := TVoltmeter.Init(E2010, LcardChannelAdcVoltage);                    // Вольтметр
end;

//--------------------------------------------------

procedure TSpectrometer.InitE2010Only;
var
  E2010: TPlata;
begin
  if (FAdcSpectrMeassure <> nil) and (FAdcLevelSignal <> nil) then
  begin
    E2010 := TPlata.PlataCreate;
    FAdcSpectrMeassure.Create(E2010);          // АЦП измерения (сигнал + поле)
    FAdcLevelSignal.Create(E2010);             // АЦП уровня сигнала
  end;
  if ReadyADC then
  begin
    FAdcLevelSignal.Prepare;
  end;
end;

//--------------------------------------------------

function TSpectrometer.Debug: boolean;
begin
{$if Defined(debug)}
  Result := True;
{$else}
  Result := False;
{$ifend}
end;

//--------------------------------------------------

function TSpectrometer.UnderThreshold: boolean;
begin
  Result := TempSensor.UnderThreshold;
end;

//--------------------------------------------------

function TSpectrometer.ReadyADC: Boolean;
begin
  Result := FAdcSpectrMeassure.Ready and FAdcLevelSignal.Ready;
end;

{ TChargerThread }

constructor TChargerThread.create(Charger: TCharger);
begin
  inherited Create(True);
  FCharger := Charger;
  Priority := tpHighest;
  FreeOnTerminate := true;
end;

//--------------------------------------------------

procedure TChargerThread.Execute;
begin
  inherited;
  sleep(1);
  FCharger.UnCharge;
end;

{ TChargerStartThread }

constructor TChargerStartThread.create(Charger: TCharger; Spectrometer: TSpectrometer);
begin
  inherited Create(True);
  FCharger := Charger;
  FSpectrometer := Spectrometer;
  Priority := tpHighest;
  FreeOnTerminate := true;
end;

//--------------------------------------------------

procedure TChargerStartThread.Execute;
var
  Unew, Unew1: real;
begin
  inherited;
  FSpectrometer.FFullyCharge := false;
  FCharger.Charge;
  Delay(1000);
  with FSpectrometer do
  begin
    repeat
      repeat
        Delay(500);
        Unew := GetChargeVoltage;
      until Unew < 1000;
      Delay(500);
      repeat
        Unew1 := GetChargeVoltage;
        Delay(500);
      until Unew1 < 1000;
    until abs(Unew - Unew1) < 1;
    Delay(500);
    FFullyCharge := True;
  end;
end;

//===================================================


procedure TSpectrometer.SetTempZeroCompensation(ZeroCorrection: double);
begin
  FTempSensor.ZeroCorrection:=ZeroCorrection;
end;

end.