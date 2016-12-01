unit FileParams;

interface
uses
  IniFiles, SysUtils, Classes, StrUtils,
  CommonTypes;
type
  TFileParam = class
  private
    FIniFile: TIniFile;
    FIniFileName: String;
    function GetValue(FullStr: String): String;  //Возвращает значение из строки вида "name=Value" результат Value
  public
    constructor CreateFileParam(FileName: String);
    function GetParamCircuit: TParameters;
    function GetRiseUpCoefSet: TPulseEdgeCoefSet;
    function GetDownCoefSet: TPulseEdgeCoefSet;
    function GetParamChField:  TLogicalCnannel;
    function GetParamChSignal: TLogicalCnannel;
    function GetParamChLevel:  TLogicalCnannel;
    function GetFlagSave: Boolean;
    function GetRateAdcLevel: WORD;
    function GetAdcRate: WORD;
    function GetDurationSpectr: WORD;
    function GetDurationLevel: WORD;    
    function GetFlagSaveDebugADCData: Boolean;
    function GetMaxErrorFit: double;
    function GetCrystalList: TStrings;
    function GetGeneratorList: TStrings;
    function GetSectionList: TStrings;
    function GetThermopairList: TStrings;
    function GetOrientationList: TStrings;
    function GetLastChangesExperiment: TLastChangesExperiment;
    function GetAutoScalePercent: byte;
    function GetLastThermoCoupleControlPointU: double;//возвращает последнюю контрольную точку согласно полиному
    function GetLastThermoCoupleRealControlPointU: double;//возвращает последнюю контрольную точку согласно реальным данным
    function GetLastFrequency: double;//возвращает последнюю частоту

    procedure SetParamChField(ChField: TLogicalCnannel);
    procedure SetParamChSignal(ChSignal: TLogicalCnannel);
    procedure SetParamChLevel(ChLevel: TLogicalCnannel);
    procedure SetFlagSave(flag: Boolean);
    procedure SetRateAdcLevel(RateAdcLevel: WORD);
    procedure SetAdcRate(RateAdc: WORD);
    procedure SetDurationSpectr(DurationSpectr: WORD);
    procedure SetDurationLevel(DurationLevel: WORD);
    procedure SetParamCircuit(Parametr: TParameters);
    procedure SetRiseUpCoefSet(Parametr: TPulseEdgeCoefSet);
    procedure SetDownCoefSet(Parametr: TPulseEdgeCoefSet);
    procedure SetFlagSaveDebugADCData(flag: Boolean);
    procedure SetMaxErrorFit(ErrorValue: double);
    procedure SetLastChangesExperiment(LastChanges: TLastChangesExperiment);
    procedure SetAutoScalePercent(Value: byte);
    procedure SetLastThermoCoupleControlPointU(Coef: double);
    procedure SetLastThermoCoupleRealControlPointU(Coef: double);
    procedure SetLastFrequnency(Coef: double);
  end;
implementation

//uses
  //TypInfo;

{ TFileParam }

constructor TFileParam.CreateFileParam(FileName: String);
begin
  inherited Create;
  FIniFileName := FileName;
end;

//-------------------------------------------------

function TFileParam.GetValue(FullStr: String): String;
begin
  Result := RightStr(FullStr, Length(FullStr) - Pos('=', FullStr));
end;

//-------------------------------------------------

function TFileParam.GetAdcRate: WORD;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := FIniFile.ReadInteger('ADC_param', 'RateAdc', 1000);
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetDownCoefSet: TPulseEdgeCoefSet;
var
  defaultK1, defaultK2,
  defaultK3: String;
begin
  defaultK1 := '44' + FormatSettings.DecimalSeparator + '6496';
  defaultK2 := '-0' + FormatSettings.DecimalSeparator + '000269184';
  defaultK3 := '0';
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    Result.k1 := StrToFloat(ReadString('ParamCalibrate', 'k1Down', defaultK1), FormatSettings);
    Result.k2 := StrToFloat(ReadString('ParamCalibrate', 'k2Down', defaultK2), FormatSettings);
    Result.k3 := StrToFloat(ReadString('ParamCalibrate', 'k3Down', defaultK3), FormatSettings);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetDurationLevel: WORD;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := FIniFile.ReadInteger('ADC_param', 'DurationLevelSignalMeassure', 10);
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetDurationSpectr: WORD;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := FIniFile.ReadInteger('ADC_param', 'DurationSpectrMeassure', 30);
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetFlagSave: Boolean;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := Boolean(FIniFile.ReadInteger('Save_param', 'Save', 1));
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetFlagSaveDebugADCData: Boolean;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := Boolean(FIniFile.ReadInteger('Save_debug', 'Save', 1));
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetMaxErrorFit: double;
var
  defaultValue: String;
begin
  defaultValue := '5E-6';
  FIniFile := TIniFile.Create(FIniFileName);
  Result := StrToFloat(FIniFile.ReadString('MaxErrorFit', 'ErrorFitValue', defaultValue), FormatSettings);
  FIniFile.Free;
end;

function TFileParam.GetLastThermoCoupleRealControlPointU: double;
var
  defaultValue: String;
begin
  defaultValue := '1571';
  FIniFile := TIniFile.Create(FIniFileName);
  Result := StrToFloat(FIniFile.ReadString('Thermopair', 'LastRealControlPoint', defaultValue), FormatSettings);
  FIniFile.Free;
end;

function TFileParam.GetLastThermoCoupleControlPointU: double;
var
  defaultValue: String;
begin
  defaultValue := '1571';
  FIniFile := TIniFile.Create(FIniFileName);
  Result := StrToFloat(FIniFile.ReadString('Thermopair', 'LastControlPoint', defaultValue), FormatSettings);
  FIniFile.Free;
end;

function TFileParam.GetLastFrequency: double;
var
  defaultValue: String;
begin
  defaultValue := '0';
  FIniFile := TIniFile.Create(FIniFileName);
  Result := StrToFloat(FIniFile.ReadString('LastExperimentCondition', 'Frequency', defaultValue), FormatSettings);
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetParamChField: TLogicalCnannel;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    Result.Number := ReadInteger('ChannelField', 'Number', 1);
    Result.Repeating := ReadInteger('ChannelField', 'Repeat', 1);
    Result.InputRange := ReadInteger('ChannelField', 'Scale', 3000);
    Result.InputSwitch := ReadInteger('ChannelField', 'Input', INPUT_GROUND);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetParamChLevel: TLogicalCnannel;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    Result.Number := ReadInteger('ChannelLevel', 'Number', 1);
    Result.Repeating := ReadInteger('ChannelLevel', 'Repeat', 1);
    Result.InputRange := ReadInteger('ChannelLevel', 'Scale', 3000);
    Result.InputSwitch := ReadInteger('ChannelLevel', 'Input', INPUT_GROUND);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetParamChSignal: TLogicalCnannel;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    Result.Number := ReadInteger('ChannelSignal', 'Number', 1);
    Result.Repeating := ReadInteger('ChannelSignal', 'Repeat', 1);
    Result.InputRange := ReadInteger('ChannelSignal', 'Scale', 3000);
    Result.InputSwitch := ReadInteger('ChannelSignal', 'Input', INPUT_GROUND);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetParamCircuit: TParameters;
var
  defaultR, defaultL,
  defaultC, defaultT,
  defaultV0: String;
begin
  defaultR := '0' + FormatSettings.DecimalSeparator + '096';
  defaultL := '0' + FormatSettings.DecimalSeparator + '0013';
  defaultC := '0' + FormatSettings.DecimalSeparator + '012';
  defaultT := '0';
  defaultV0 := '0' + FormatSettings.DecimalSeparator + '0013';

  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    Result[byte(prmR)] := StrToFloat(ReadString('ParamCircuit', 'R', defaultR), FormatSettings);
    Result[byte(prmL)] := StrToFloat(ReadString('ParamCircuit', 'L', defaultL), FormatSettings);
    Result[byte(prmC)] := StrToFloat(ReadString('ParamCircuit', 'C', defaultC), FormatSettings);
    Result[byte(prmT)] := StrToFloat(ReadString('ParamCircuit', 'T0', defaultT), FormatSettings);
    Result[byte(prmV0)] := StrToFloat(ReadString('ParamCircuit', 'V0', defaultV0), FormatSettings);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetRateAdcLevel: WORD;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := FIniFile.ReadInteger('ADC_param', 'RateAdcLevel', 1000);
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetRiseUpCoefSet: TPulseEdgeCoefSet;
var
  defaultK1, defaultK2,
  defaultK3: String;
begin
  defaultK1 := '43' + FormatSettings.DecimalSeparator + '5590087117728';
  defaultK2 := '-0' + FormatSettings.DecimalSeparator + '000155757756450876';
  defaultK3 := '0';
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    Result.k1 := StrToFloat(ReadString('ParamCalibrate', 'k1Up', defaultK1), FormatSettings);
    Result.k2 := StrToFloat(ReadString('ParamCalibrate', 'k2Up', defaultK2), FormatSettings);
    Result.k3 := StrToFloat(ReadString('ParamCalibrate', 'k3Up', defaultK3), FormatSettings);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

function TFileParam.GetCrystalList: TStrings;
var
  s: Tstrings;
begin
  s := TStringList.Create;
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.ReadSectionValues('Crystal', s);
  FIniFile.Free;
  Result := s;
end;

//-------------------------------------------------

function TFileParam.GetGeneratorList: TStrings;
var
  s: Tstrings;
begin
  s := TStringList.Create;
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.ReadSectionValues('Generator', s);
  FIniFile.Free;
  Result := s;
end;

//-------------------------------------------------

function TFileParam.GetOrientationList: TStrings;
var
  s: Tstrings;
begin
  s := TStringList.Create;
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.ReadSectionValues('Orientation', s);
  FIniFile.Free;
  Result := s;
end;

//-------------------------------------------------

function TFileParam.GetSectionList: TStrings;
var
  s: Tstrings;
begin
  s := TStringList.Create;
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.ReadSectionValues('Section', s);
  FIniFile.Free;
  Result := s;
end;

//-------------------------------------------------

function TFileParam.GetThermopairList: TStrings;
var
  s: Tstrings;
begin
  s := TStringList.Create;
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.ReadSectionValues('Thermopair', s);
  FIniFile.Free;
  Result := s;
end;

//-------------------------------------------------

function TFileParam.GetLastChangesExperiment: TLastChangesExperiment;
var
  s: Tstrings;
begin
  s := TStringList.Create;
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.ReadSectionValues('LastChangesExperiment', s);
  FIniFile.Free;

  Result.Crystal := GetValue(S[0]);     //образец
  Result.Generator := GetValue(S[1]);   //генератор
  Result.Section := GetValue(S[2]);     //секция
  Result.Thermopair := GetValue(S[3]);  //термопара
  Result.Orientation := GetValue(S[4]); //ориентация
  Result.Comment := GetValue(S[5]);     //комментарий
end;

//-------------------------------------------------

function TFileParam.GetAutoScalePercent: byte;
begin
  FIniFile := TIniFile.Create(FIniFileName);
  Result := StrToInt(FIniFile.ReadString('AutoScaleGauge', 'Scale', '80'));
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetAdcRate(RateAdc: WORD);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteInteger('ADC_param', 'RateAdc', RateAdc);
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetDownCoefSet(Parametr: TPulseEdgeCoefSet);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    WriteString('ParamCalibrate', 'k1Down', FloatToStr(Parametr.k1, FormatSettings));
    WriteString('ParamCalibrate', 'k2Down', FloatToStr(Parametr.k2, FormatSettings));
    WriteString('ParamCalibrate', 'k3Down', FloatToStr(Parametr.k3, FormatSettings));
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetDurationLevel(DurationLevel: WORD);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteInteger('ADC_param', 'DurationLevelSignalMeassure', DurationLevel);
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetDurationSpectr(DurationSpectr: WORD);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteInteger('ADC_param', 'DurationSpectrMeassure', DurationSpectr);
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetFlagSave(flag: Boolean);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteInteger('Save_param', 'Save', byte(flag));
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetFlagSaveDebugADCData(flag: Boolean);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteInteger('Save_debug', 'Save', byte(flag));
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetParamChField(ChField: TLogicalCnannel);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    WriteInteger('ChannelField', 'Number', ChField.Number);
    WriteInteger('ChannelField', 'Repeat', ChField.Repeating);
    WriteInteger('ChannelField', 'Scale', ChField.InputRange);
    WriteInteger('ChannelField', 'Input', ChField.InputSwitch);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetParamChLevel(ChLevel: TLogicalCnannel);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    WriteInteger('ChannelLevel', 'Number', ChLevel.Number);
    WriteInteger('ChannelLevel', 'Repeat', ChLevel.Repeating);
    WriteInteger('ChannelLevel', 'Scale', ChLevel.InputRange);
    WriteInteger('ChannelLevel', 'Input', ChLevel.InputSwitch);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetParamChSignal(ChSignal: TLogicalCnannel);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    WriteInteger('ChannelSignal', 'Number', ChSignal.Number);
    WriteInteger('ChannelSignal', 'Repeat', ChSignal.Repeating);
    WriteInteger('ChannelSignal', 'Scale', ChSignal.InputRange);
    WriteInteger('ChannelSignal', 'Input', ChSignal.InputSwitch);
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetParamCircuit(Parametr: TParameters);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    WriteString('ParamCircuit', 'R', FloatToStr(Parametr[prmR], FormatSettings));
    WriteString('ParamCircuit', 'L', FloatToStr(Parametr[prmL], FormatSettings));
    WriteString('ParamCircuit', 'C', FloatToStr(Parametr[prmC], FormatSettings));
    WriteString('ParamCircuit', 'T0', FloatToStr(Parametr[prmT], FormatSettings));
    WriteString('ParamCircuit', 'V0', FloatToStr(Parametr[prmV0], FormatSettings));
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetRateAdcLevel(RateAdcLevel: WORD);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteInteger('ADC_param', 'RateAdcLevel', RateAdcLevel);
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetRiseUpCoefSet(Parametr: TPulseEdgeCoefSet);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  with FIniFile do
  begin
    WriteString('ParamCalibrate', 'k1Up', FloatToStr(Parametr.k1, FormatSettings));
    WriteString('ParamCalibrate', 'k2Up', FloatToStr(Parametr.k2, FormatSettings));
    WriteString('ParamCalibrate', 'k3Up', FloatToStr(Parametr.k3, FormatSettings));
  end;
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetMaxErrorFit(ErrorValue: double);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteString('MaxErrorFit', 'ErrorFitValue', FloatToStr(ErrorValue, FormatSettings));
  FIniFile.Free;
end;

procedure TFileParam.SetLastThermoCoupleControlPointU(Coef: double);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteString('Thermopair', 'LastControlPoint', FloatToStr(Coef, FormatSettings));
  FIniFile.Free;
end;

procedure TFileParam.SetLastThermoCoupleRealControlPointU(Coef: double);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteString('Thermopair', 'LastRealControlPoint', FloatToStr(Coef, FormatSettings));
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetLastChangesExperiment(
  LastChanges: TLastChangesExperiment);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteString('LastChangesExperiment', '0', LastChanges.Crystal);
  FIniFile.WriteString('LastChangesExperiment', '1', LastChanges.Generator);
  FIniFile.WriteString('LastChangesExperiment', '2', LastChanges.Section);
  FIniFile.WriteString('LastChangesExperiment', '3', LastChanges.Thermopair);
  FIniFile.WriteString('LastChangesExperiment', '4', LastChanges.Orientation);
  FIniFile.WriteString('LastChangesExperiment', '5', LastChanges.Comment);
  FIniFile.Free;
end;

//-------------------------------------------------


procedure TFileParam.SetAutoScalePercent(Value: byte);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteString('AutoScaleGauge', 'Scale', IntToStr(Value));
  FIniFile.Free;
end;

//-------------------------------------------------

procedure TFileParam.SetLastFrequnency(Coef: double);
begin
  FIniFile := TIniFile.Create(FIniFileName);
  FIniFile.WriteString('LastExperimentCondition', 'Frequency', FloatToStr(Coef, FormatSettings));
  FIniFile.Free;
end;

end.
