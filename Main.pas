{************************************************************}
{                                                            }
{              Модуль Main                                   }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 26 ноября 2008                             }
{                                                            }
{************************************************************}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ComCtrls, ToolWin, Menus, StdCtrls, ExtCtrls, TeeProcs,
  TeEngine, Chart, Series, XPMan,
  Charger, Sp_unit, Spectrm, Basic, M_Gauge, ProgrammOptions, CommonTypes,
  FileParams, Graph, Viewspc, UnitFormSummary,tempr_s;

const
  w = 'w';
  r = 'r';
  a = 'a';

type
  TMainForm = class(TForm)
    PanelControls: TPanel;
    PanelChart: TPanel;
    EditFreq: TEdit;
    LFreq: TLabel;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    MainMenuCommands: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    F51: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    SButNew: TSpeedButton;
    ButCharge: TButton;
    ButStart: TButton;
    ButStart_Charge: TButton;
    LV: TLabel;
    LVolt: TLabel;
    LT: TLabel;
    LTemp: TLabel;
    SButOpen: TSpeedButton;
    SButSave: TSpeedButton;
    SButStart: TSpeedButton;
    SButCharge: TSpeedButton;
    SButClear: TSpeedButton;
    SButViewSpectr: TSpeedButton;
    SmallChart: TChart;
    Series1: TFastLineSeries;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    LAnge: TLabel;
    EditAnge: TEdit;
    LMaxField: TLabel;
    LField: TLabel;
    StatusBar: TStatusBar;
    SysTimer: TTimer;
    Group: TGroupBox;
    N10: TMenuItem;
    PrevButton: TButton;
    NextButton: TButton;
    MainMenuService: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    ShapeIndicator: TShape;
    WatchTemp: TMenuItem;
    LabelFrontBack: TLabel;
    ThresholdEdit: TEdit;
    Label5: TLabel;
    ComboBoxAmplifier: TComboBox;
    GainLabel: TLabel;
    N15: TMenuItem;
    AngleUpDown: TUpDown;
    CompareButton: TButton;
    ULabel: TLabel;
    LUTerm: TLabel;
    SignalTimer: TTimer;
    SignalCurrentLabel: TLabel;
    PaintGauge: TPaintBox;
    PanelPaintGauge: TPanel;
    Label6: TLabel;
    InitLcard: TMenuItem;
    Options: TMenuItem;
    XPManifest: TXPManifest;
    LabelErrorFit: TLabel;
    LabelErrorFitValue: TLabel;
    PanelGaugeControls: TPanel;
    LabelLevelScale: TLabel;
    ComboBoxLevelScale: TComboBox;
    SpeedButtonLevelScaleDown: TSpeedButton;
    SpeedButtonLevelScaleUp: TSpeedButton;
    GroupBoxInfoSpectr: TGroupBox;
    LabelFreq: TLabel;
    LabelAngle: TLabel;
    LabelFreqValue: TLabel;
    LabelAngleValue: TLabel;
    LabelFrontBackValue: TLabel;
    LabelTemp: TLabel;
    LabelTempValue: TLabel;
    MainMenuExperiment: TMenuItem;
    PropetyExp: TMenuItem;
    CheckBoxWatchTemp: TCheckBox;
    Label1: TLabel;
    ButtonGaugeScaleTune: TButton;
    FitScaleGauge: TMenuItem;
    LabelGaugeScaleValue: TLabel;
    Label2: TLabel;
    EditTempCorrection: TEdit;
    Label3: TLabel;
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure SButOpenClick(Sender: TObject);
    procedure SButSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SysTimerTimer(Sender: TObject);
    procedure ButChargeClick(Sender: TObject);
    procedure ButStartClick(Sender: TObject);
    procedure SButChargeClick(Sender: TObject);
    procedure SButStartClick(Sender: TObject);
    procedure SButViewSpectrClick(Sender: TObject);
    procedure ButStart_ChargeClick(Sender: TObject);
    procedure SmallChartDblClick(Sender: TObject);
    procedure PrevButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure WatchTempClick(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure SmallChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure AngleUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure CompareButtonClick(Sender: TObject);
    procedure SignalTimerTimer(Sender: TObject);
    procedure PaintGaugeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OptionsClick(Sender: TObject);
    procedure InitLcardClick(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure ThresholdEditChange(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure ComboBoxLevelScaleChange(Sender: TObject);
    procedure SpeedButtonLevelScaleDownClick(Sender: TObject);
    procedure SpeedButtonLevelScaleUpClick(Sender: TObject);
    procedure PropetyExpClick(Sender: TObject);
    procedure CheckBoxWatchTempClick(Sender: TObject);
    procedure ButtonGaugeScaleTuneClick(Sender: TObject);
    procedure FitScaleGaugeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditTempCorrectionChange(Sender: TObject);
  private
    { Private declarations }
    IniFileParam: TFileParam;
    Spectrometer: TSpectrometer;
    FGraph: TGraph;
    FLevelVolt: double;       // уровень сигнала в вольтах
    CrystalFont: TFont;       //Индикаторный шрифт
    Experiment: boolean;

    procedure SetPanelsAlign;
    procedure Start(HowStart: byte = 0); // старт
    function PrevSpectrum: Boolean;      // спектр пред
    function NextSpectrum: Boolean;      // спектр след
    procedure ViewSpectrum;              // показать спектр
    procedure UpdateData(flag: byte);    // обновить данные на форме или в программе с формы
    procedure UpdateDataOnTimer;         // обновить данные переодично (по таймеру)
    procedure UpdateLevelContorls;       // обновляет содержание комбобоксов для настройки уровня
    procedure AutoSetScaleGauge(caliber: byte);  // выставляет шкалу, подбирая масштаб
    procedure SetCrystalFont;
  public
    { Public declarations }
    Gauge: TGaugeGeneral;
  end;


var
  MainForm: TMainForm;

implementation

Uses
   CompareFormModule;
{$R *.dfm}

//==================================================

procedure TMainForm.UpdateData(flag: byte);
var
  Spectrum: TSpectrum;
begin
  //из программы в форму
  if flag = SpectrometerToForm then
  begin
    //Получим текущий спектр
    Spectrum := Spectrometer.Sb.GetCurrent;
    if Spectrum <> nil  then
    begin
      with Spectrum.SpectrDescription do
      begin
        // покажем ошибку подгонки по полю (если она больше, показываем красным цветом)
        if Spectrum.SpectrDescription.ErrorFit < Spectrometer.PulseGenerator.MaxErrorFit then
          LabelErrorFitValue.Font.Color := clGreen
        else
          LabelErrorFitValue.Font.Color := clRed;
        LabelErrorFitValue.Caption := FloatToStrF(Spectrum.SpectrDescription.ErrorFit, ffGeneral, 3, 1) + ' ';

        // покажем текущий фронт
        if FrontBack = fbFront then
          LabelFrontBackValue.Caption := 'передний'
        else
          LabelFrontBackValue.Caption := 'задний';

        // Остальные параметры
        LabelFreqValue.Caption := FloatToStrF(Frequency, ffFixed, 5, 3, FormatSettings) + ' ';
        LabelAngleValue.Caption := FloatToStrF(Angle, ffFixed, 5, 1, FormatSettings) + ' ';
        LabelTempValue.Caption := FloatToStrF(Temperature, ffFixed, 5, 2, FormatSettings) + ' ';
      end;
    end
    else   // Если нет текущего спектра
    begin
      LabelErrorFitValue.Caption := '0 ';
      LabelFrontBackValue.Caption := 'неизвестно';
      LabelFreqValue.Caption := '0 ';
      LabelTempValue.Caption := '0 ';
      LabelAngleValue.Caption := '0 ';
    end;
  end; // из программы в форму

  //из формы в программу
  if flag = FormToSpectrometer then
  begin
    with Spectrometer.Description do
    begin
      Frequency := ConvertStringInFloat(EditFreq.Text);
      Angle := ConvertStringInFloat(EditAnge.Text);
      AmplifierScale := ConvertStringInFloat(ComboBoxAmplifier.Text);
      ADCFrequency := Spectrometer.AdcSpectr.Frequency;
      ADCFieldDivSignal := IntToStr(Spectrometer.AdcSpectr.ChannelField.Repeating) +
        '/' + IntToStr(Spectrometer.AdcSpectr.ChannelSignal.Repeating);

    end;
  end;
end;

//--------------------------------------------------

procedure TMainForm.UpdateDataOnTimer;
var
  Volt: real;
begin
  Volt := 0;
  StatusBar.Panels[1].Text := 'Time '+TimeToStr(Time);
  InitLcard.Enabled := not Spectrometer.ReadyADC;
  if Spectrometer.ReadyADC and (not Spectrometer.Debug) then
    if (not Spectrometer.isBusy ) then
    begin
      // если нужно выполняем автострат записи
      if Spectrometer.FullyCharge then
        Start(0);

      Volt := Spectrometer.GetChargeVoltage;
      //запрещаем старт если батарея разряжена
      if Volt < 100 then
      begin
        ButStart.Enabled := false;
        LVolt.Font.Color := clBlack;
      end
      else
      begin
        ButStart.Enabled := true;
        LVolt.Font.Color := clGreen;
      end;

      //температура
      if WatchTemp.Checked then
        if Spectrometer.UnderThreshold then
        begin
          LTemp.Font.Color := clGreen;
          ShapeIndicator.Brush.Color := clLime;
        end
        else
        begin
          LTemp.Font.Color := clRed;
          //мигаем лампочкой и пищим
          windows.Beep(1500,100);
          if ShapeIndicator.Brush.Color = clPurple then
            ShapeIndicator.Brush.Color := clRed
          else
            ShapeIndicator.Brush.Color := clPurple
        end
      else
      begin
        LTemp.Font.Color := clGreen;
        ShapeIndicator.Brush.Color := clGray;
      end;
  end;

  LVolt.Caption := FloatToStrF(Volt, ffFixed, 5, 2, FormatSettings) + ' ';
  LTemp.Caption := FloatToStrF(Spectrometer.GetTemperature,ffFixed, 5, 2, FormatSettings) + ' ';
  LUTerm.Caption := FloatToStr(Spectrometer.GetThermopareVoltage, FormatSettings) + ' ';
  LField.Caption := FloatToStrF(Spectrometer.GetMaxField(Volt) ,ffFixed, 5, 2, FormatSettings) + ' ';
end;

//--------------------------------------------------

procedure TMainForm.ThresholdEditChange(Sender: TObject);
var
  T: double;
begin
  //Значение температуры для сигнализации
  T := Spectrometer.TempSensor.Threshold;
  if CheckOnNumber(ThresholdEdit, T) then
    Spectrometer.TempSensor.Threshold := T;
end;

//--------------------------------------------------

procedure TMainForm.EditChange(Sender: TObject);
var
  F: double;
begin
  //Проверяем значение на число
  CheckOnNumber(TEdit(Sender), F);
end;

//--------------------------------------------------

procedure TMainForm.N3Click(Sender: TObject);
begin
  OpenDialog.InitialDir := 'D:\TestAFMR\';
  OpenDialog.Filter := 'Все файлы (*.*)|*.*|Файлы данных (*.dat)|*.dat';
  OpenDialog.FilterIndex := 2;
  if OpenDialog.Execute then
  begin
    //
  end;
end;

//--------------------------------------------------

procedure TMainForm.N5Click(Sender: TObject);
begin
  SaveDialog.InitialDir := 'D:\TestAFMR';
  SaveDialog.Filter := 'Все файлы (*.*)|*.*|Файлы данных (*.dat)|*.dat';
  SaveDialog.FilterIndex := 2;
  if SaveDialog.Execute then
  begin
    //
  end;
end;

//--------------------------------------------------

procedure TMainForm.N6Click(Sender: TObject);
begin
  MainForm.Close;
end;

//--------------------------------------------------

procedure TMainForm.SButOpenClick(Sender: TObject);
begin
  N3Click(Sender);
end;

//--------------------------------------------------

procedure TMainForm.SButSaveClick(Sender: TObject);
begin
  N5Click(Sender);
end;

//--------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);

begin
  SysTimer.Enabled := False;
  SignalTimer.Enabled := False;

  //для отладки когда нужны случайные значения для индикатора
  Randomize;

  // Файл параметров программы
  IniFileParam := TFileParam.CreateFileParam(GetCurrentDir + '\Settings.ini');

  // Спектрометр
  Spectrometer := TSpectrometer.Create(IniFileParam);

  //Доступность в меню для повторной инициализации модуля Е20-10
  InitLcard.Enabled := not Spectrometer.ReadyADC;

  // Прибор - полоска индикатор
  PaintGauge.Width := PanelPaintGauge.Width - 8;
  Gauge := TGaugeGeneral.CreateGauge(PaintGauge.Canvas.Handle, PaintGauge.Width, PaintGauge.Height);

  //Начальный порог для слежения за температурой
  ThresholdEdit.Text := FloatToStr(Spectrometer.TempSensor.Threshold);

  //Обновим контролы для оправления индикатором
  UpdateLevelContorls;

  if Spectrometer.Debug then
    Caption := Caption + '(отладка)';

  Experiment := False;


  //Шрифты
  SetCrystalFont;

  //Обновление данных по таймерам
  SysTimer.Enabled := True;
  SignalTimer.Enabled := True;
  EditFreq.Text:=FloatToStr(Spectrometer.IniFileParam.GetLastFrequency);

end;

//--------------------------------------------------

procedure TMainForm.SysTimerTimer(Sender: TObject);
begin
  UpdateDataOnTimer;
  if not Spectrometer.Debug then
    if not Experiment then
    begin
      SysTimer.Enabled := false;
      PropetyExpClick(Sender); //Начало работы (покажем форму свойств эксперимента)
      Experiment := True;
      SysTimer.Enabled := True;
    end;
      
end;

//--------------------------------------------------

procedure TMainForm.ButChargeClick(Sender: TObject);
begin
  Spectrometer.Charge;
end;

//--------------------------------------------------

procedure TMainForm.ButStartClick(Sender: TObject);
begin
  Start(0);
end;

//--------------------------------------------------

procedure TMainForm.ButStart_ChargeClick(Sender: TObject);
begin
  Start(1);
end;

//--------------------------------------------------

procedure TMainForm.Start(HowStart: byte = 0);
begin
  if (not Spectrometer.Debug) and (not Spectrometer.ReadyADC) then
  begin
    MessageBox(MainForm.Handle, 'Установка не готова к измерению! Проверте готовность платы E2010', 'Предупреждение', MB_OK + MB_ICONWARNING);
    exit;
  end;
  UpdateData(FormToSpectrometer);
  SignalTimer.Enabled := False;
  SysTimer.Enabled := False;
  Delay(100);

  if HowStart = 0 then
    Spectrometer.StartRecord
  else
    Spectrometer.AutoCharge; // в системном таймере проверяем флаг и стартуем

  ViewSpectrum;
  Delay(10);
  SignalTimer.Enabled := True;
  SysTimer.Enabled := True;

  Spectrometer.IniFileParam.SetLastFrequnency(StrToFloat(EditFreq.Text));
end;

//--------------------------------------------------

procedure TMainForm.SButChargeClick(Sender: TObject);
begin
  ButChargeClick(Sender);
end;

//--------------------------------------------------

procedure TMainForm.SButStartClick(Sender: TObject);
begin
  ButStartClick(Sender);
end;

//--------------------------------------------------

procedure TMainForm.SButViewSpectrClick(Sender: TObject);
begin
//
end;

//--------------------------------------------------

procedure TMainForm.SmallChartDblClick(Sender: TObject);
begin
  FormView.Show;
end;

//--------------------------------------------------

procedure TMainForm.PrevButtonClick(Sender: TObject);
begin
  PrevSpectrum;
end;

//--------------------------------------------------

procedure TMainForm.NextButtonClick(Sender: TObject);
begin
  NextSpectrum;
end;

//--------------------------------------------------

procedure TMainForm.N12Click(Sender: TObject);
begin
  Spectrometer.TempSensor.Calibrate(TliquidHelium);
  Spectrometer.IniFileParam.SetLastThermoCoupleControlPointU(Spectrometer.TempSensor.ControlPoint);
  Spectrometer.IniFileParam.SetLastThermoCoupleRealControlPointU(Spectrometer.TempSensor.Unorm);
end;

//--------------------------------------------------

procedure TMainForm.N13Click(Sender: TObject);
begin
  winexec('calc.exe', SW_SHOW);
end;

//--------------------------------------------------

procedure TMainForm.WatchTempClick(Sender: TObject);
begin
  WatchTemp.Checked := not WatchTemp.Checked;
  CheckBoxWatchTemp.Checked := WatchTemp.Checked;
end;

//--------------------------------------------------

procedure TMainForm.CheckBoxWatchTempClick(Sender: TObject);
begin
   WatchTemp.Checked := CheckBoxWatchTemp.Checked;
end;

//--------------------------------------------------

procedure TMainForm.N15Click(Sender: TObject);
begin
  Spectrometer.TempSensor.Calibrate(TliquidNitrogen);
  Spectrometer.IniFileParam.SetLastThermoCoupleControlPointU(Spectrometer.TempSensor.ControlPoint);
  Spectrometer.IniFileParam.SetLastThermoCoupleRealControlPointU(Spectrometer.TempSensor.Unorm);
end;

//--------------------------------------------------

procedure TMainForm.SmallChartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  CX, CY: real;
  S: String;
begin
  CX := SmallChart.Series[0].XScreenToValue(X);
  CY := SmallChart.Series[0].YScreenToValue(Y);

  SmallChart.Canvas.Pen.Color := clBlack;
  SmallChart.Canvas.Brush.Color := SmallChart.Color;
  SmallChart.Canvas.Font.Height := 14;
  Str(CX:5:2,S);
  SmallChart.Canvas.TextOut(10, 2, 'Поле = ' + S + ' кЭ');
  Str(CY:5:2,S);
  SmallChart.Canvas.TextOut(10, 16, 'Сигнал = ' + S);
end;

//--------------------------------------------------

procedure TMainForm.AngleUpDownClick(Sender: TObject; Button: TUDBtnType);
var
  CurAngle: double;
begin
  if not TryStrToFloat(EditAnge.Text, CurAngle) then
    CurAngle := 0;
  if Button = btNext then
    CurAngle := CurAngle + 4
  else
    CurAngle := CurAngle - 4;
  EditAnge.Text := FloatToStr(CurAngle);
end;

//--------------------------------------------------

procedure TMainForm.CompareButtonClick(Sender: TObject);
begin
  CompareForm.Spectrometer := Spectrometer;
  CompareForm.SpeedButtonReload.Click;
  CompareForm.Show;
end;

//--------------------------------------------------

procedure TMainForm.SignalTimerTimer(Sender: TObject);
var
  i: integer;
  LevelStr, Zero: String;
begin
  FLevelVolt := 0;
  if Spectrometer.ReadyADC then
    Spectrometer.AdcLevel.Prepare;
    FLevelVolt := ABS(Spectrometer.AdcLevel.GetLevelSignalInVolt);

  //Если отладка показываем на индикаторе случайные значения
  if Spectrometer.Debug then
    FLevelVolt := Random /10;

  //Обновим величину уровня сигнала в мВ на формочке
  LevelStr := FloatToStrF(FLevelVolt * 1E3, ffFixed, 6, 2, FormatSettings);
  Zero := '';
  for i := 1 to 7 - length(LevelStr) do
  begin
    Zero := Zero + '0';
  end;
  SignalCurrentLabel.Caption := Zero + LevelStr + ' ';
//  SignalCurrentLabel.Caption := IntToStr(Round(FLevelVolt * 1E3));

  //Покажем уровень на приборе
  Gauge.ShowLevel(FLevelVolt);

  //Обновим значение шкалы прибора в мВ на формочке
  LabelGaugeScaleValue.Caption := IntToStr(Gauge.LGauge.Scale);
end;

//--------------------------------------------------

procedure TMainForm.PaintGaugeClick(Sender: TObject);
begin
  Gauge.LGauge.Resetpeak;
end;

//--------------------------------------------------

procedure TMainForm.FormShow(Sender: TObject);
begin

  //Автомасштаб панелей
  SetPanelsAlign;

  //Создаем объект Граф
  FGRaph := TGraph.Create(SmallChart, ViewSpc.FormView.BigChart, Spectrometer);
  FGRaph.WhatView := SpectrumViewMode;
  FGRaph.ShowLine := False;
  ViewSpc.FormView.Graph := FGraph;

  //Размеры и положение главной формы
  MainForm.Width := 1024;
  MainForm.Height := 750;
  MainForm.Position := poDesktopCenter;
end;

//--------------------------------------------------

procedure TMainForm.OptionsClick(Sender: TObject);
begin
  try
    ProgrammOptions.FormOptions.Spectrometer := Spectrometer;
    ProgrammOptions.FormOptions.ShowModal;
  except
    MessageBox(MainForm.Handle, 'Невозможно открыть форму!', 'Ошибка',
      MB_OK + MB_ICONERROR);
  end;
  UpdateLevelContorls;
end;

//--------------------------------------------------

procedure TMainForm.InitLcardClick(Sender: TObject);
begin
  //Если возники какие-то ошибки при работе с картой вызываем повторно конструктор самой платы
  if not Spectrometer.ReadyADC then
    Spectrometer.InitE2010Only;
end;

//--------------------------------------------------

procedure TMainForm.N9Click(Sender: TObject);
begin
  if MessageBox(MainForm.Handle, 'Вы уверены, что хотите очистить базу спектров?',
    'АФМР-спектрометр', MB_YESNO + MB_ICONQUESTION) = IDYES	 then
      Spectrometer.SB.Clear;
end;

//--------------------------------------------------

procedure TMainForm.FormResize(Sender: TObject);
begin
  {Передаем приборчику (полоске индикатору) новые размеры области рисования
  иначе он некорректно отображатся при изменении размеров главной формы}
  Gauge.LGauge.ResizeGauge(PaintGauge.Width,PaintGauge.Height);
end;

//--------------------------------------------------

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Перелистываем спектр назад "Page Up"
  if Key = 33 then
    PrevSpectrum;
  //Перелистываем спектр назад "Page Down"
  if Key = 34 then
    NextSpectrum;
  //Покажем последний спектр "End"
  if Key = 35 then
  begin
    Spectrometer.SB.EndBase;
    ViewSpectrum;
  end;
  //Покажем первый спектр "Home"
  if Key = 36 then
  begin
    Spectrometer.SB.BeginBase;
    ViewSpectrum;
  end;
end;

//--------------------------------------------------

function TMainForm.NextSpectrum: Boolean;
begin
  Result := FGraph.NextSpectrum;
  UpdateData(SpectrometerToForm);
end;

//--------------------------------------------------

function TMainForm.PrevSpectrum: Boolean;
begin
  Result := FGraph.PrevSpectrum;
  UpdateData(SpectrometerToForm);
end;

//--------------------------------------------------

procedure TMainForm.ViewSpectrum;
begin
  FGraph.ViewSpectr;
  UpdateData(SpectrometerToForm);
end;

//--------------------------------------------------

procedure TMainForm.FormActivate(Sender: TObject);
begin
  UpdateData(SpectrometerToForm);
end;

//--------------------------------------------------

procedure TMainForm.SetPanelsAlign;
begin
  PanelChart.Align := alClient;
  SmallChart.Align := alClient;
  PanelPaintGauge.Align := alRight;
  PaintGauge.Align := alClient;
  PanelControls.Align := alTop;
  PanelGaugeControls.Align := alRight;
  PanelGaugeControls.BevelOuter := bvNone;
end;

//Процедуры для быстрого управления индикатором уровня сигнала

procedure TMainForm.UpdateLevelContorls;
begin
  //Значения по умолчанию
  ComboBoxLevelScale.ItemIndex := Spectrometer.AdcLevel.ChannelLevel.InputRange;
end;

//--------------------------------------------------

procedure TMainForm.ComboBoxLevelScaleChange(Sender: TObject);
var
  Channel: TLogicalCnannel;
begin
  // Индексы прописаны в самом чекбоксе
  Channel := Spectrometer.AdcLevel.ChannelLevel;
  Channel.InputRange := ComboBoxLevelScale.ItemIndex;
  Spectrometer.AdcLevel.ChannelLevel := Channel;
  //Сразу поставим новую шкалу прибора
  if Gauge.LGauge.Scale > StrToInt(ComboBoxLevelScale.Text) then
    Gauge.SetScale(StrToInt(ComboBoxLevelScale.Text));
  //Применим новые значения для АЦП уровня
  if Spectrometer.ReadyADC then
   begin
    Spectrometer.AdcLevel.Prepare;
   end;
end;

//--------------------------------------------------
//Уменьшаем шкалу на 10%
procedure TMainForm.SpeedButtonLevelScaleDownClick(Sender: TObject);
var
  NewScale: integer;
begin
  NewScale := Round(Gauge.LGauge.Scale - (Gauge.LGauge.Scale / 100 * 10));
  if not (NewScale < 10) then
    Gauge.SetScale(NewScale);
end;

//--------------------------------------------------
//Увеличиваем шкалу на 10%
procedure TMainForm.SpeedButtonLevelScaleUpClick(Sender: TObject);
var
  NewScale: WORD;
begin
  NewScale := Round(Gauge.LGauge.Scale + (Gauge.LGauge.Scale / 100 * 10));
  if not (NewScale > StrToInt(ComboBoxLevelScale.Text)) then
    Gauge.SetScale(NewScale);  
end;

//--------------------------------------------------
//Форма свойств эксперимента

procedure TMainForm.PropetyExpClick(Sender: TObject);
begin
  FormSummary.Spectrometer := Spectrometer;
  FormSummary.ShowModal;
end;

//--------------------------------------------------

procedure TMainForm.AutoSetScaleGauge(caliber: byte);
var
  Value: double;
  NewScale: integer;
begin
  Value := FLevelVolt * 1000;   //mV
  NewScale := Round((Value/caliber)*100);
  Gauge.SetScale(NewScale);
  Gauge.LGauge.PeakValue:=0;
end;

//--------------------------------------------------
//по кнопке "подогнать"
procedure TMainForm.ButtonGaugeScaleTuneClick(Sender: TObject);
begin
  FitScaleGaugeClick(Sender);
end;

//--------------------------------------------------
//Из главного меню
procedure TMainForm.FitScaleGaugeClick(Sender: TObject);
begin
  AutoSetScaleGauge(Spectrometer.AutoGaugeScale);
end;

//--------------------------------------------------

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Выгрузим шрифт
  if RemoveFontResource(PChar(Spectrometer.Files.FontsRoot + 'crystal.TTF')) Then
    SendMessage($FFFF, wm_FontChange, 0, 0);
end;


//--------------------------------------------------

procedure TMainForm.SetCrystalFont;
var
  FontRes: integer;
begin
  //Загрузим свой красивый шрифт для отображения цифровых значений
  FontRes := AddFontResource(PChar(Spectrometer.Files.FontsRoot + 'crystal.TTF'));
  if FontRes <> 0 then
  begin
    SendMessage($FFFF, wm_FontChange, 0, 0);
    CrystalFont := TFont.Create;
    CrystalFont.Name := 'Crystal';
    CrystalFont.Charset := ANSI_CHARSET;
    CrystalFont.Size := 14;

    //Заменим шрифты на метках
    SignalCurrentLabel.Font := CrystalFont;
    SignalCurrentLabel.Font.Color := clBlue;
    LVolt.Font := CrystalFont;
    LField.Font := CrystalFont;
    LField.Font.Color := clGray;
    LTemp.Font := CrystalFont;
    LUTerm.Font := CrystalFont;
    LUTerm.Font.Color := clGray;

    //метки инфо о спектре
    LabelFreqValue.Font := CrystalFont;
    LabelFreqValue.Font.Color := clGray;
    LabelErrorFitValue.Font := CrystalFont;
    LabelAngleValue.Font := CrystalFont;
    LabelAngleValue.Font.Color := clGray;
    LabelTempValue.Font := CrystalFont;
    LabelTempValue.Font.Color := clGray;

  end;
end;


//==================================================

procedure TMainForm.EditTempCorrectionChange(Sender: TObject);
begin
  Spectrometer.ZeroCompensationTempSensor:=ConvertStringInFloat(EditTempCorrection.Text);
end;

end.



