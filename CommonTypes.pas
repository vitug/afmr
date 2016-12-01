// ������ ��� �������� ����� ����� � �������
unit CommonTypes;

interface
uses
  Windows, SysUtils, StdCtrls, Graphics;
const
  // �������� �������� ����� �� ������ E2010
  // ������� ��������� ���������� �������� ���������� ������ E20-10
	RANGE_3000mv				=	($00);
	RANGE_1000mv 				=	($01);
	RANGE_300mv 				=	($02);

	// ������� ��������� ����� ����������� �������� ������ ������ E20-10
	INPUT_GROUND				=	($00);
	INPUT_SIGNAL  			=	($01);

  // ������� ������� ���������� ����
  prmV0 = 0;
  prmL  = 1;
  prmR  = 2;
  prmT  = 3;
  prmC  = 4;

  // ���� ����� ���������� ��� ����������� �������� ���� ���
  PointForZero = 100;

  //����� ����� � ������������� � ������ ������ � ��� �������������� ��� �������
  FileDebugComment = 3;
  //����� ��������� � ������ ����� ������ � ��� ������������� ��� ������� (�������� '123' '456' '789')
  FileDebugParam = 3;

  //����� ������������ ��� ������� ������ (�����-��������� ��� ���������-�����)
  FormToSpectrometer = 0;
  SpectrometerToForm = 1;

type
  // ������ (������) ��� ����� ������
  TShortrArray = array of SHORT;

  // ������ ������ 
  TChannelData = Packed Record
    quantization_step: SHORT;
    voltage: double;
    time: double;
  end;

  TADC_DATA = array of TChannelData; // ������ � ��� ��� ��������� �� ������������ ������

  TAdcDataOfChannel = array of array of TChannelData;  // ������ ���� �������

  TLogicalCnannel = record
    Number      :WORD;   // ����� ��������� ����������� ������
    Repeating   :WORD;   // ����� ���������� ������
    InputRange  :WORD;   // ������� ��������, �
    InputSwitch :WORD;   // �������� �����
  end;

  TControlTable = array of TLogicalCnannel; // ������������ ����� ������� 256 ���������.

  TPulseEdgeCoefSet = record //����� ������������� ��� ��������� � ������� ������
    k1,
    k2,
    k3: double;
  end;

  PTParameters = ^TParameters;
  TParameters = array [0..4] of Double; // ����� ���������� ����

  TFrontBack = (fbFront, fbBack, fbFull); //�������� ��� ������ ����� �������� ��� �������
  TUnitSignal = (unVolt, unDiskret);//������� ��������� ������� ��� ������ ��� ��������

  TKindOfUnit = record //������� ��������� � ��� (������ ��������)
    Quant: SHORT;
    Voltage: double;
  end;

  TSpectrXY = record    // ������� ������� ������: X- ��������� ���� Y- ����� ����������
    x: double;
    y: TKindOfUnit;
  end;

  TSpectrData = array of TSpectrXY; // ������ ������ �������

  TFileADC_Data = array of String[30]; //������ �� ����� ������ ��� (��� �������)
  //0 - �����
  //1 - �������� � ���������
  //2 - �������� � �������

  // ������ ���������� �������
  TSpectrDescription = record
    Crystal,                        // �������
    Generator,                      // ������ ����������
    Section,                        // ������
    Thermopair,                     // ���������
    Orientation,                    // ���������� �������
    Comment: String;                // ������������
    Temperature: double;            // �����������
    Frequency: double;              // ������� ��� ����������
    Angle: double;                  // ���� ��������
    ChargeVoltage: double;          // ���������� ������ ���.
    FrontBack: TFrontBack;          // ����� ��������
    ErrorFit: double;               //������ ������������������
    ThermopairVoltage: double;      // ���������� �� ���������
    AmplifierScale: double;         // ����� ��������������� ���������
    ADCFrequency: integer;          // ������� ���
    ADCFieldDivSignal: string;      // �������� ������� ��� 1(����)/10(������)
  end;

  //������ ��� �������� ��������� ������ ������������� � ��������� ������������
  //������������ ��� ���������� � ������ �� �����
  TLastChangesExperiment =  record
    Crystal,                        // �������
    Generator,                      // ������ ����������
    Section,                        // ������
    Thermopair,                     // ���������
    Comment,                        // ������������
    Orientation: String;            // ���������� �������
  end;

  //�������� �������� ��������� ������ � ����� � ��������� �������
  function ConvertStringInFloat(Value: String): double;

  //��������� ���� ����� TEdit �� ������������ ����� ����� 
  function CheckOnNumber(EObject: TEdit; var Value: Double): boolean;

var
  FormatSettings: TFormatSettings;

implementation

function ConvertStringInFloat(Value: String): double;
begin
  Result := 0;
  Value := StringReplace(Value, ',', DecimalSeparator, []);
  Value := StringReplace(Value, '.', DecimalSeparator, []);
  TryStrToFloat(Value, Result);
end;

//--------------------------------------------------------------------------

function CheckOnNumber(EObject: TEdit; var Value: Double): boolean;
var
  a: double;
  s: String;
begin
  Result := false;
  a := 0;
  s := StringReplace(EObject.Text, '.', DecimalSeparator, []);
  s := StringReplace(s, ',', DecimalSeparator, []);
  //EObject.Text := s;
  if not TryStrToFloat(s, a) then
  begin
    EObject.Color := clRed;
    Result := false;
  end
  else
  begin
    EObject.Color := clWindow;
    Value := a;
    Result := true;
  end;
end;

//--------------------------------------------------------------------------

initialization
  //�������� ����������� ��������� ��������������
  GetLocaleFormatSettings(SysLocale.DefaultLCID, FormatSettings);
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ShortDateFormat := 'yyyy_MM_dd';
  FormatSettings.LongTimeFormat := 'HH_mm_ss';
end.
