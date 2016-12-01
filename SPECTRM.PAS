{************************************************************}
{                                                            }
{                 Модуль ХХХ                                 }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 05 декабря 2008                            }
{                                                            }
{************************************************************}
Unit spectrm;

Interface

uses
  Basic, Charger, tempr_s, Mathematic, CommonTypes, FileRelis,
  SysUtils, Dialogs, Windows;

type

    PTPulseGenerator = ^TPulseGenerator;
    TPulseGenerator = class
    private
      FBeginParamCircuit: TParameters; //начальные параметры подгонки (Параметры цепи)
      FParamCircuit: TParameters;      //подогнанные параметры цепи / подгонки
      FRiseUpCoefSet: TPulseEdgeCoefSet;// Коэффициенты уравнения расчета поля (передний фронт)
      FDownCoefSet: TPulseEdgeCoefSet;  // Коэффициенты уравнения расчета поля (задний фронт)
      FField: TADC_DATA;               //Массив поля (обработанный)
      FTimeMidleRealField: double;     //Время середины реального импульса(максимум поля), но с откорректированным временем 
      FTimeBeginRealField: double;     //Время начала реального импульса(минимум поля) без коррекции времени
      FTimeEndRealField: double;       //Время конца реального импульса(минимум поля)  без коррекции времени
      FError: double;                  //Ошибка среднеквадратичная
      FMaxErrorFit: double;            //Ошибка среднеквадратичная максимальная (задается вручную, для сравнения с расчетной)
      procedure FindMaxOfDiff(Signal: TADC_DATA);  //Находит максимум импульса по минимуму производной
      procedure FindMaxClassic(Signal: TADC_DATA); // Обычный поиск максимума по значению поля
      procedure FindMaxOfModel(Signal: TADC_DATA); // Поиск максимума используя модель для левого и правого фронта
      procedure SetRiseCoefSet(const Value: TPulseEdgeCoefSet);
      procedure SetDownCoefSet(const Value: TPulseEdgeCoefSet);
      procedure SetBeginParamCircuit(const Value: TParameters);
      function RecalcTime(AdcData, ResizeAdcData: TADC_DATA): TADC_DATA;   // Пересчитывает время из массива данных АЦП учитывая частоту и приводит к виду 0..КонецИзмерения
    public
      constructor Create; //Конструктор
      function GetField(Time: real;  ChargeVoltage: double; PulseEdge: TFrontBack = fbFront): real;  {Дает значение поля в момент времени time с начальными параметрами}
      function Fit (Field: TADC_DATA; ChargeVoltage: double): integer;   {Выполняет подгонку поля}
      procedure FindMax(Signal: TADC_DATA); // Поиск максимума импульса
      function GetFieldFit(Time: real;  ChargeVoltage: double; PrCirct: TParameters; PulseEdge: TFrontBack): real;  {Дает значение поля (после подгонки) в момент времени time}
      function GetFitValue(Time: real; ChargeVoltage: double; PrCirct: TParameters): real;  {Дает значение после подгонки в момент времени time}
      function RecalcSignal(Signal: TADC_DATA): TADC_DATA;
      function RecalcSignalFull(Signal: TADC_DATA): TADC_DATA; // Вырезаем сигнал от начала импульса и до конца измерения
      destructor Done;
      property RiseUpCoefSet: TPulseEdgeCoefSet read FRiseUpCoefSet write SetRiseCoefSet;
      property DownCoefSet: TPulseEdgeCoefSet read FDownCoefSet write SetDownCoefSet;
      property BeginParamCircuit: TParameters read FBeginParamCircuit write SetBeginParamCircuit;
      property ErrorFit: double read FError;
      property MaxErrorFit: double read FMaxErrorFit write FMaxErrorFit;
    end;

    PTSpectrum = ^TSpectrum;
    TSpectrum = class{Содержит спектр, температуру, частоту и др.}
    private
      FSpectrDescription: TSpectrDescription; // дополнительная информация эксперимента
      FSpectrData: TSpectrData;       // массив спектра
      FPulseData: TADC_DATA;          // Массив поля (обработанный)
      FSignalData: TADC_DATA;         // Массив сигнала (обработанный)
      FFileNumber: integer;             //номер файла под которым сохранен спектр
      FParamCircuit_Fit: TParameters;   // параметры цепи после подгонки (нужно при постороении теор.импульса в режиме просмотра)
    protected
      procedure copy_linear (From, To_: TSpectrData);
      procedure copy_linearADCData(From, To_: TADC_DATA);
    public
      constructor InitEstimateFieldFit(Signal_: TADC_DATA; PulseGen_: TPulseGenerator;
        SpectrDescription_: TSpectrDescription);
      constructor InitCopyClass(From_: TSpectrum);
      destructor Done; virtual;
      property SpectrData: TSpectrData read FSpectrData;
      property PulseData: TADC_DATA read FPulseData;
      property SignalData: TADC_DATA read FSignalData;
      property SpectrDescription: TSpectrDescription read FSpectrDescription;
      property FileNumber: integer read FFileNumber write FFileNumber;
      property ParamCircuit_Fit: TParameters read FParamCircuit_Fit;
    end;

    PTDataQueue = ^TDataQueue;
    {содержит элемент очереди содержащая спектр и указатели на предыдущую и следующую очередь}
    TDataQueue = class
    private
      FContent: TSpectrum;
      FPrev: TDataQueue;
      FNext: TDataQueue;
    public
      constructor Init(Content_: TSpectrum; Prev_, Next_: TDataQueue);
      destructor Done;
      property Content: TSpectrum read FContent write FContent;
    end;

    PTSpectrumBase = ^TSpectrumBase;
    TSpectrumBase = class
    private
       FData: TDataQueue;
       FOrigin: TDataQueue;
       FEndofBase: TDataQueue;
       FIterator: word;
       FIteratorEnd: word;

       procedure SaveHeading(var F: Text; Description: TSpectrDescription);    //Записывает заголовок в файл
     public
       constructor Init;
       procedure Add(DataIn: TSpectrum);        //добавление сперктра в очередь
       procedure Delete;                        //удаление текущего спектра
       procedure DeleteInBegin;
       function Up: boolean;                    //переход к следующему елементу
       function Down: boolean;                  //переход к предыдущему элементу
       procedure BeginBase;                     //переход к началу
       procedure EndBase;                       //переход к концу очереди
       procedure SaveData(NameofFile: String);  //запись спектра на диск
       procedure SavePulse(NameofFile: String); //запись импульса поля на диск
       procedure SaveSignal(NameofFile: String);// запись сигнала от времени на диск
       procedure Clear;                         //очистка очереди
       function GetCurrent: TSpectrum;
       property Data: TDataQueue read FData write FData;
    end;

implementation



//==================================================

constructor  TSpectrum.InitEstimateFieldFit(Signal_: TADC_DATA; PulseGen_: TPulseGenerator;
        SpectrDescription_: TSpectrDescription);
var
  i, j: longint;
  CalcField: Double;

begin
  inherited Create;
  FFileNumber := 0; // номер файла (обновляется при вызове из StartRecord)
  // Сохраним поле (нужно для графического отображения и для записи его в отладочных целях)
  FPulseData := PulseGen_.FField;
  // Сохраним сигнал (нужно для записи его в отладочных целях)
  FSignalData := Signal_;
  // Параметры цепи для данного импульса для расчета (также нужно для графического отображения)
  FParamCircuit_Fit := PulseGen_.FParamCircuit;

  //Найдем максимум импульса (для разделения на передний и задний фронт)
  PulseGen_.FindMax(Signal_);
  
  //Описание спектра
  FSpectrDescription := SpectrDescription_;
  //Ошибка среднеквадрат по полю
  FSpectrDescription.ErrorFit := PulseGen_.FError;

{формируем развертку по передней или задней части импульса в зависимости от FrontBack}

//------развертка по переднему фронту-------
  j := 0;
  if FSpectrDescription.FrontBack = fbFront then
  begin
    for i := 0 to length(Signal_) - 1 do
    begin
      if Signal_[i].time <= PulseGen_.FTimeMidleRealField then
      begin
        SetLength(FSpectrData, length(FSpectrData) + 1);
        FSpectrData[j].x := PulseGen_.GetFieldFit(Signal_[i].time, FSpectrDescription.ChargeVoltage, FParamCircuit_Fit, fbFront);
        FSpectrData[j].y.Quant := Signal_[i].quantization_step;
        FSpectrData[j].y.Voltage := Signal_[i].voltage;
        inc(j);
      end;
    end; //end for
  end; // end if FrontBack

  //------развертка по заднему фронту-------
  if FSpectrDescription.FrontBack = fbBack then
  begin
    for i := 0 to length(Signal_) - 1 do
    begin
      if Signal_[i].time >= PulseGen_.FTimeMidleRealField then
      begin
        CalcField := PulseGen_.GetFieldFit(Signal_[i].time, FSpectrDescription.ChargeVoltage, FParamCircuit_Fit, fbBack);
        {поскольку "СигналПоглощения" справа не органичен,
        делаем проверку, когда поле станет отрицательным и прерываем цикл}
        if CalcField < 0 then
          break;
        SetLength(FSpectrData, length(FSpectrData) + 1);
        FSpectrData[j].x := CalcField;
        FSpectrData[j].y.Quant := Signal_[i].quantization_step;
        FSpectrData[j].y.Voltage := Signal_[i].voltage;
        inc(j);
      end;
    end; //end for
  end; // end if FrontBack

  FFileNumber := 1;

end;

//--------------------------------------------------

constructor TSpectrum.InitCopyClass(From_: TSpectrum);
begin
  SetLength(FSpectrData, Length(From_.FSpectrData));
  copy_linear(From_.FSpectrData, FSpectrData);
  SetLength(FPulseData, Length(From_.FPulseData));
  copy_linearADCData(From_.FPulseData, FPulseData);
  SetLength(FSignalData, Length(From_.FSignalData));
  copy_linearADCData(From_.FSignalData, FSignalData);
  FSpectrDescription := From_.FSpectrDescription;
  FFileNumber := From_.FFileNumber;
  FParamCircuit_Fit := From_.FParamCircuit_Fit;
end;

//--------------------------------------------------

procedure TSpectrum.copy_linear(From, To_: TSpectrData);
var
  i: integer;
begin
  for i := low(From) to High(From) do
    To_[i] := From[i];
end;

//--------------------------------------------------

procedure TSpectrum.copy_linearADCData(From, To_: TADC_DATA);
var
  i: integer;
begin
  for i := low(From) to High(From) do
    To_[i] := From[i];

end;

//--------------------------------------------------

destructor TSpectrum.Done;
begin
//
end;

//===================================================

constructor TDataQueue.Init(Content_: TSpectrum; Prev_, Next_: TDataQueue);
begin
   if Content_ <> nil then
   begin
     FContent := TSpectrum.InitCopyClass(Content_);
     Content_.Done;
     FPrev := Prev_;
     FNext := Next_;
   end;       
end;

//--------------------------------------------------

destructor TDataQueue.Done;
begin
  FContent.Done;
end;

//===================================================

constructor TSpectrumBase.Init;
begin
  FData := nil;
  FOrigin := Data;
  FIterator := 0;
end;

//--------------------------------------------------

procedure TSpectrumBase.Add(DataIn: TSpectrum);
var
  DataTemp: TDataQueue;
begin
  if DataIn <> nil then
  begin
    EndBase;
    FIterator := FIterator + 1;
    DataTemp := FData;
    FData := TDataQueue.Init(DataIn, DataTemp, nil);
    if DataTemp = nil then
    begin
      FOrigin := Data;
      FData.FNext := nil;
      FData.FPrev := nil;
    end
    else
      FData.FPrev.FNext := FData;
     if Data.FNext <> nil then
     begin
       FData.FNext.FPrev := FData;
       FIteratorEnd := FIteratorEnd + 1;
     end
     else
     begin
       FEndofBase := FData;
       FIteratorEnd := FIterator;
     end;
  end;

end;

//--------------------------------------------------

procedure TSpectrumBase.Delete;
var
   TD: TDataQueue;
begin
    if FData <> nil then
    begin
      if FIterator > 1 then
        FIterator := FIterator - 1;
      TD := FData;
      if FData.FPrev <> nil then
      begin
        FData.FPrev.FNext := FData.FNext;
        FData := FData.FPrev;
      end
      else
      begin
        FData := FData.FNext;
        FOrigin := FData;
        if FData <> nil then
          FData.FPrev := nil;
      end;
      TD.Done;
    end;
end;

//--------------------------------------------------

function TSpectrumBase.Up: boolean;
begin
  Result := False;
  if (FData <> nil) and (FData <> nil) then
  begin
    if FData.FNext <> nil then
    begin
      FIterator := FIterator + 1;
      FData := FData.FNext;
      Result := True;
    end
    else
      Result := False;
    end;
end;

//--------------------------------------------------

function TSpectrumBase.Down: boolean;
begin
  Result := False;
  if (FData <> nil) and (FData <> nil) then
  begin
    if FData.FPrev <> nil then
    begin
      FIterator := FIterator - 1;
      FData := FData.FPrev;
      Result := True;
     end
     else
      Result := False;
    end;
end;

//--------------------------------------------------

procedure TSpectrumBase.BeginBase;
begin
  if FData <> nil then
  begin
    FData := FOrigin;
    FIterator := 1;
  end;
end;

//--------------------------------------------------

procedure TSpectrumBase.EndBase;
begin
  if FData <> nil then
  begin
    if FData.FNext <> nil then
    FData := FEndofBase;
    FIterator := FIteratorEnd;
  end;
end;

//--------------------------------------------------

procedure TSpectrumBase.SaveHeading(var F: Text; Description: TSpectrDescription);
var
  StrFrontBack: String;
begin
  Writeln(F, '___Summary_information___');
  Writeln(F, 'Object= ', Description.Crystal);
  Writeln(F, 'Generator= ', Description.Generator);
  Writeln(F, 'Section= ', Description.Section);
  Writeln(F, 'Thermopair= ', Description.Thermopair);
  Writeln(F, 'Orientation= ', Description.Orientation);
  Writeln(F, 'Remarks= ', Description.Comment);
  Writeln(F, 'ADC_Frequency= ', Description.ADCFrequency, 'KHz');
  Writeln(F, 'Amount(Field/Signal)= ', Description.ADCFieldDivSignal);
  Writeln(F, 'Charge_Voltage= ', FloatToStrF(Description.ChargeVoltage , ffFixed, 6, 3, FormatSettings ), 'V');
  Writeln(F, 'Frequency= ', FloatToStrF(Description.Frequency, ffFixed, 6, 3 , FormatSettings), 'GHz');
  Writeln(F, 'Temperature= ', FloatToStrF(Description.Temperature, ffFixed, 6, 3, FormatSettings), 'K');
  Writeln(F, 'Voltage_on_termopare= ', FloatToStrF(Description.ThermopairVoltage, ffFixed, 6, 3, FormatSettings), 'mkV');
  Writeln(F, 'Rotation_Angle= ', FloatToStrF(Description.Angle, ffFixed, 6, 3, FormatSettings), 'Degree');
  // какой фронт пишем
  case Description.FrontBack of
    fbFront:  StrFrontBack := 'Front';
    fbBack: StrFrontBack := 'Back';
    fbFull: StrFrontBack := 'Full';
  end;
  Writeln(F, 'Front_Back= ', StrFrontBack);
  Writeln(F, 'ErrorFit= ', FloatToStrF(Description.ErrorFit, ffGeneral, 3, 1, FormatSettings));
  Writeln(F, 'Amplifier_Scale= ', FloatToStrF(Description.AmplifierScale, ffFixed, 6, 3, FormatSettings));

  //16 строк имеем
  //пропускаем еще 3 строки
  Writeln(F);Writeln(F);Writeln(F);
end;

//--------------------------------------------------

procedure TSpectrumBase.SaveData(NameofFile: String);
var
  F: Text;
  i: integer;
begin
  AssignFile(F, NameofFile);
  Rewrite(F);
  try
    if FData <> nil then
    begin
      if length(FData.FContent.FSpectrData ) > 1 then
      begin
        With FData.FContent do
        begin
          SaveHeading(F, FSpectrDescription);
          //Пишем даные
          for i := 0 to Length(FSpectrData) - 1 do
            Writeln(F, FloatToStrF(FSpectrData[i].x, ffFixed, 10, 6, FormatSettings), '  ', FloatToStrF(FSpectrData[i].y.Voltage, ffFixed, 9, 6, FormatSettings));
        end; //With FData.FContent
      end
      else
        Writeln(F, 'No Data');
    end //if Data<>nil
    else
      Writeln(F,'Error spectrBase. Data is nil');
  finally
    CloseFile(F);
  end;
end;

//--------------------------------------------------

procedure TSpectrumBase.SavePulse(NameofFile: String);
var
  F: Text;
  i: integer;
  SpDescript: TSpectrDescription;
begin
  AssignFile(F, NameofFile);
  Rewrite(F);
  try
    if FData <> nil then
    begin
      if length(FData.FContent.FPulseData) > 1 then
      begin
        with FData.FContent do
        begin
          SpDescript := FSpectrDescription;
          SpDescript.FrontBack := fbFull;
          SaveHeading(F, SpDescript);
          //Пишем даные
          for i := 0 to Length(FPulseData) - 1 do
            Writeln(F, FloatToStr(FPulseData[i].Time, FormatSettings), '  ', FloatToStr(FPulseData[i].Voltage, FormatSettings));
        end;
      end
      else
        Writeln(F, 'No Data');
    end     //if Data<>nil
    else
      Writeln(F,'Error spectrBase. Data is nil');
  finally
    CloseFile(F);
  end;
//
end;

//--------------------------------------------------

procedure TSpectrumBase.SaveSignal(NameofFile: String);
var
  F: Text;
  i: integer;
  SpDescript: TSpectrDescription;
begin
  AssignFile(F, NameofFile);
  Rewrite(F);
  try
    if FData <> nil then
    begin
      if length(FData.FContent.FSignalData) > 1 then
      begin
        with FData.FContent do
        begin
          SpDescript := FSpectrDescription;
          SpDescript.FrontBack := fbFull;
          SaveHeading(F, SpDescript);
          //Пишем даные
          for i := 0 to Length(FSignalData) - 1 do
            Writeln(F, FloatToStr(FSignalData[i].Time, FormatSettings), '  ', FloatToStr(FSignalData[i].Voltage, FormatSettings));
        end;
      end
      else
        Writeln(F, 'No Data');
    end     //if Data<>nil
    else
      Writeln(F,'Error spectrBase. Data is nil');
  finally
    CloseFile(F);
  end;
//
end;

//--------------------------------------------------

procedure TSpectrumBase.Clear;
begin
  if FData <> nil then
  begin
    EndBase;
    while FData.FPrev <> nil do
    begin
      Down;
      FData.FNext.Done;
    end;
    FData.Done;
    FData.FNext := nil;
    FData := nil;
    FIterator := 0;
 end;
end;

//--------------------------------------------------

procedure TSpectrumBase.DeleteInBegin;
var
  Td: TDataQueue;
begin
  if (FData <> nil)  and (FIterator > 1) then
  begin
    Td := FOrigin;
    FOrigin := FOrigin.FNext;
    FOrigin.FPrev := nil;
    Td.Done;
    Dec(FIterator);
  end;
end;

//--------------------------------------------------

function TSpectrumBase.GetCurrent: TSpectrum;
begin
  if (FData = nil) then
    Result := nil
  else
    Result := FData.FContent;
end;

//====================================================

constructor TPulseGenerator.Create;
begin
  inherited Create;
  FError := 0;
end;

//--------------------------------------------------

function TPulseGenerator.RecalcTime(AdcData, ResizeAdcData: TADC_DATA): TADC_DATA;
var
  i: longint;
begin
  for i := 0 to length(ResizeAdcData) - 1 do
  begin
    ResizeAdcData[i].time := ResizeAdcData[i].time - FTimeBeginRealField;
  end;
  Result := ResizeAdcData;
end;

//--------------------------------------------------

function TPulseGenerator.fit(Field: TADC_DATA; ChargeVoltage: double): integer;
var
  i, j: longint;
  ZeroShiftQuant: integer;
  Max, Min: SHORT;
  MaxIndex, MinIndex: longint;
  ZeroShiftVolt: double;
  TempArrayField: TADC_DATA;
  TempArrayFieldLeft, TempArrayFieldRight: TADC_DATA;
  s: String;
  tmpArrayX, tmpArrayY :TDataXY;
  TempParam: TParameters;
begin
  Result := -3;
  //Сделаем вырезку импульса из общего массива точек
  {Узнаем смещение нуля АЦП, для этого
  посмотрим амплитуду первых PointForZero точек (это начало отсчета АЦП и будем считать его нулем).
  }
  ZeroShiftQuant := 0; //Сдвиг в дискретах
  ZeroShiftVolt := 0;  //Сдвиг в вольтах
  for i := 0 to PointForZero - 1  do
  begin
    ZeroShiftVolt := ZeroShiftVolt + Field[i].voltage;
    ZeroShiftQuant := ZeroShiftQuant + Field[i].quantization_step;
  end;
  ZeroShiftVolt := ZeroShiftVolt / PointForZero;
  ZeroShiftQuant := Round(ZeroShiftQuant / PointForZero);

  //Выпоним нормализацию записанного импульса с учетом смещения нуля
  for i := 0 to length(Field) - 1 do
  begin
    Field[i].quantization_step :=  Field[i].quantization_step - ZeroShiftQuant;
    Field[i].voltage :=  Field[i].voltage - ZeroShiftVolt;
  end;

  //Найдем максимум импульса, точнее индекс в массиве поля, где оно максимально
  //Цикл слева на право
  Max := 0;
  for i := 0 to length(Field) - 1 do
  begin
    if Field[i].quantization_step > Max then
    begin
      Max := Field[i].quantization_step;
      MaxIndex := i;
    end;
  end;

  //Найдем минимум импульса, точнее индекс в массиве поля, где оно минимально
  //Цикл делаем от максимума вправо
  Min := 10000;
  for i := MaxIndex to length(Field) - 1  do
  begin
    if Field[i].quantization_step < Min then
    begin
      Min := Field[i].quantization_step;
      MinIndex := i;
    end;
  end;

  //Сохраним передний фронт в временный массив
  //Шагаем от максимума влево до нуля
  j := 0;
  for i := MaxIndex downto 0 do
  begin
    if Field[i].quantization_step < 0 then
      break;
    SetLength(TempArrayFieldLeft, length(TempArrayFieldLeft) + 1);
    TempArrayFieldLeft[j] := Field[i];
    inc(j);
  end;

  //Сохраним задний фронт в временный массив
  //Шагаем от максимума вправо до минимума
  j := 0;
  for i := MaxIndex to MinIndex do
  begin
    SetLength(TempArrayFieldRight, length(TempArrayFieldRight) + 1);
    TempArrayFieldRight[j] := Field[i];
    inc(j);
  end;

  //Объеденим передний и задний фронты в полный импульс
  //Временный массив TempArrayField
  //Передний (левый)
  j := 0;
  for i := High(TempArrayFieldLeft) downto Low(TempArrayFieldLeft) do
  begin
    SetLength(TempArrayField, length(TempArrayField) + 1);
    TempArrayField[j] := TempArrayFieldLeft[i];
    inc(j);
  end;
  //Задний (правый)
  for i := Low(TempArrayFieldRight) to High(TempArrayFieldRight) do
  begin
    SetLength(TempArrayField, length(TempArrayField) + 1);
    TempArrayField[j] := TempArrayFieldRight[i];
    inc(j);
  end;

  //Если мы получили импульс, а не мусор тогда выполняем
  if Length(TempArrayField) >  100 then // 100 примерно, если точек меньше наверняка это не импульс
  begin
    // Находим время начала и конца импульса
    FTimeBeginRealField := TempArrayField[0].time;
    FTimeEndRealField := TempArrayField[length(TempArrayField) - 1].time;

    {После того, как вырезали импульс из общих данных с АЦП необходимо
     откорректировать время в нем 0..КонецИмпульса,
     чтобы подгонка корректно работала}
    TempArrayField := RecalcTime(Field, TempArrayField);

    //Запомним обработанный импульс в классе пульсгенератора
    SetLength(FField, length(TempArrayField));
    FField := TempArrayField;

    //создаем массив данных для подгонки
    SetLength(tmpArrayX, length(TempArrayField));
    SetLength(tmpArrayY, length(TempArrayField));
    for i := 0 to Length(TempArrayField) - 1 do
    begin
      tmpArrayX[i] := TempArrayField[i].time;
      tmpArrayY[i] := TempArrayField[i].voltage / ChargeVoltage;
    end;

    //Сначала используем начальные параметры
    FParamCircuit := FBeginParamCircuit;

    //Временные параметры для передачи в функцию
    TempParam := FBeginParamCircuit;
    Result := fitNewton(@TempParam, tmpArrayX, tmpArrayY, Length(tmpArrayX));
    if Result = 0 then
    begin
      //Погдгонка прошла нормально, обновим параметры цепи для расчетов
      FParamCircuit := TempParam;
    end;
  end; //if length(TempFieldArray) > 100

  //Подсчитаем ошибку (расчет - эксперимент)^2/кол-во точек
  FError := 0;
  if Length(TempArrayField) > 0 then
  begin
    for i := 0 to Length(TempArrayField) - 1 do
    begin
      FError := FError +
        SQR(func(@FParamCircuit, TempArrayField[i].time) * ChargeVoltage - TempArrayField[i].voltage);
    end;
    FError := FError / Length(TempArrayField);
  end;

  if Result < 0 then
  begin
    s := 'Не удалось выполнить подгонку' +
      #13 + 'Расчеты будут выполнены с начальными параметрами' +
      #13 + 'возможно соленоид не охладился.';
    MessageBox(HWND(nil), PChar(s), 'Внимание', MB_OK+MB_ICONWARNING);
  end;
end;

//--------------------------------------------------

//Ищем максимум поля по минимому производной
procedure TPulseGenerator.FindMaxOfDiff(Signal: TADC_DATA);
var
  Min: double;
  MaxTime: double;
  i: integer;
begin
  //Находим время половины импульса т.е. макисмум импульса
  MaxTime :=  FField[length(FField) - 1].time;
  Min := 1000;
  for i := 0 to Length(Signal) - 1  do
  begin
    if Signal[i].time <= MaxTime then
    begin
      if ABS(diff(@FParamCircuit, Signal[i].time)) < Min then
      begin
        Min := ABS(diff(@FParamCircuit, Signal[i].time));
        FTimeMidleRealField := Signal[i].time;
      end;
    end; //if
  end;
end;

//--------------------------------------------------
//Ищем максимум поля
procedure TPulseGenerator.FindMaxClassic(Signal: TADC_DATA);
var
  Max: double;
  MaxTime: double;
  i: integer;
begin
  //Находим время половины импульса т.е. макисмум импульса
  MaxTime :=  FField[length(FField) - 1].time;
  Max := 0;
  for i := 0 to Length(Signal) - 1  do
  begin
    if Signal[i].time <= MaxTime then
    begin
      if func(@FParamCircuit, Signal[i].time) > Max then
      begin
        Max := func(@FParamCircuit, Signal[i].time);
        FTimeMidleRealField := Signal[i].time;
      end;
    end; //if
  end;
end;

//--------------------------------------------------
//Ищем максимум поля по минимальной разности значений на переднем и заднем фронте
procedure TPulseGenerator.FindMaxOfModel(Signal: TADC_DATA);
var
  Min: double;
  MaxTime: double;
  i: integer;
  fieldFront:double;
  fieldBack:double;
begin
  //Находим время половины импульса т.е. макисмум импульса
  Min := 10000;
  MaxTime :=  FField[length(FField) - 1].time;
  for i := 0 to Length(Signal) - 1  do
  begin
    if Signal[i].time <= MaxTime then
    begin
      fieldBack := GetFieldFit(Signal[i].time, 220, FParamCircuit, fbBack);
      fieldFront := GetFieldFit(Signal[i].time, 220, FParamCircuit, fbFront);
      if Abs(fieldFront - fieldBack) < Min then
      begin
        Min := Abs(fieldFront - fieldBack);
        FTimeMidleRealField := Signal[i].time;
      end;
    end; //if
  end;

end;

//--------------------------------------------------

procedure TPulseGenerator.FindMax(Signal: TADC_DATA);
begin
  //Если коэфф-ты для расчета поля разные применяем FindMaxOfModel
  if (FRiseUpCoefSet.k1 <> FDownCoefSet.k1) or (FRiseUpCoefSet.k2 <> FDownCoefSet.k2) or
    (FRiseUpCoefSet.k3 <> FDownCoefSet.k3) then
      FindMaxOfModel(Signal)
  else
    FindMaxClassic(Signal);
end;

//--------------------------------------------------

function TPulseGenerator.GetFieldFit(Time: real;  ChargeVoltage: double; PrCirct: TParameters; PulseEdge: TFrontBack): real;
var
  f: Double;
  CoefSet: TPulseEdgeCoefSet;
begin
  f := func(@PrCirct, Time) * ChargeVoltage;

  if PulseEdge = fbFront then
    CoefSet := FRiseUpCoefSet
  else
    CoefSet := FDownCoefSet;

  if (Time >= PrCirct[prmT]) then
    Result := CoefSet.k1 * (f + CoefSet.k2 * diff(@PrCirct, Time) * ChargeVoltage) + CoefSet.k3
  else
    Result := 0;

end;

//--------------------------------------------------
//Возвращает значение функции, которая описывает импульс
function TPulseGenerator.GetFitValue(Time: real; ChargeVoltage: double; PrCirct: TParameters): real;
begin
  Result := func(@PrCirct , Time) * ChargeVoltage;
end;

//--------------------------------------------------
//Используется для приблизительной оценки напряженности магнитного поля, когда идет заряд конденс.
function TPulseGenerator.GetField(Time: real;  ChargeVoltage: double; PulseEdge: TFrontBack = fbFront): real;
var
  f: Double;
  CoefSet: TPulseEdgeCoefSet;

begin
  f := func(@FBeginParamCircuit, Time) * ChargeVoltage;

  if PulseEdge = fbFront then
    CoefSet := FRiseUpCoefSet
  else
    CoefSet := FDownCoefSet;

  if (Time >= FBeginParamCircuit[prmT]) then
    Result := CoefSet.k1 * (f + CoefSet.k2 * diff(@FBeginParamCircuit, Time) * ChargeVoltage) + CoefSet.k3
  else
    Result := 0;

end;

//--------------------------------------------------
{Вырезка "Сигнала поглощения" из всего сигнала по каналу АЦП.
в интервале времени импульса}
function TPulseGenerator.RecalcSignal(Signal: TADC_DATA): TADC_DATA;
var
  i, j: longint;
  TempArraySignal: TADC_DATA;

begin
  j := 0;
  for i := 0 to length(Signal) - 1 do
  begin
    if (Signal[i].time >= FTimeBeginRealField) and (Signal[i].time <= FTimeEndRealField) then
    begin
      inc(j);
      SetLength(TempArraySignal, j);
      TempArraySignal[j - 1] := Signal[i];
    end;
  end;

   {После того, как вырезали сигнал из общих данных с АЦП необходимо
   откорректировать время в нем 0..КонецСигнала c учетом времени начала импульса
   }
 Result := RecalcTime(Signal, TempArraySignal);
end;

//--------------------------------------------------
{Вырезка "Сигнала поглощения" из всего сигнала по каналу АЦП.
в интервале Началоимпульса..legth(канал АЦП сигнала поглощения)}
function TPulseGenerator.RecalcSignalFull(Signal: TADC_DATA): TADC_DATA;
var
  i, j: longint;
  TempArraySignal: TADC_DATA;

begin
  j := 0;
  for i := 0 to length(Signal) - 1 do
  begin
    if (Signal[i].time >= FTimeBeginRealField) then
    begin
      inc(j);
      SetLength(TempArraySignal, j);
      TempArraySignal[j - 1] := Signal[i];
    end;
  end;

  {После того, как вырезали сигнал из общих данных с АЦП необходимо
   откорректировать время в нем 0..КонецСигнала c учетом времени начала импульса
  }
 Result := RecalcTime(Signal, TempArraySignal);

end;

//--------------------------------------------------

Destructor TPulseGenerator.Done;
begin
//
end;

//--------------------------------------------------

procedure TPulseGenerator.SetRiseCoefSet(const Value: TPulseEdgeCoefSet);
begin
  FRiseUpCoefSet := Value;
end;

//--------------------------------------------------

procedure TPulseGenerator.SetDownCoefSet(const Value: TPulseEdgeCoefSet);
begin
  FDownCoefSet := Value;
end;

//--------------------------------------------------

procedure TPulseGenerator.SetBeginParamCircuit(const Value: TParameters);
begin
  FBeginParamCircuit := Value;
end;

//==================================================


end.
