unit Lcard;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Math,
  Lusbapi, //������ ��� ������ � ������
  CommonTypes;

type
  TPlata = class
  private
    // ��������� ������ E20-10
    pModule: ILE2010;
    // ������ ���������� Rtusbapi.dll
	  DllVersion: DWORD;
	  // ������������� ����������
	  ModuleHandle: THandle;
	  // �������� ������
	  ModuleName: String;
	  // �������� ������ ���� USB
	  UsbSpeed: BYTE;
    // �������� ���� � ��������� ���� ��� ��������������
    StrUsbSpeed: String;
    // ��������� � ������ ����������� � ������
	  ModuleDescription: MODULE_DESCRIPTION_E2010;
	  // ��������� ���������� ������ ���
	  ap: ADC_PARS_E2010;
	  // ����� ����������������� ����
    UserFlash: USER_FLASH_E2010;
    // ��������� � ����������� ������� �� ����/����� ������
    IoReq: IO_REQUEST_LUSBAPI;
    //������� ������ � ���
    AdcData: TAdcDataofChannel;
    // ���-�� �������� � ������� ReadData
  	DataStep: DWORD;
    // ������������ ����������� ������� � ��
    Duration: WORD;
    // ������� ����� ������ � ���
  	AdcRate: double;
    // ������� ������
    KadrRate: double;
    // ����������� ��������
    KadrDelay: double;
    //����������� ������� ������ �������
    ControlTable: TControlTable;

    // ��������� �� ����� ��� ������
	  AdcBuffer: TShortrArray;

    // ������ ���������� �����
   // Status: boolean;

    procedure AbortProgram(ErrorString: string; AbortionFlag: boolean = false);  //��������� ���������

    procedure ParseData();                                      // ������ ������
  public
    constructor PlataCreate();                                  // �����������
    destructor  Destroy;
    procedure AddChannel(Channel: TLogicalCnannel);             // ��������� ���������� ����� � ����������� �������
    procedure ClearControlTable();                              // ������� ����������� �������
    procedure Fill_ADC_PARS_2010;                               // �������������� ��������� ������ ���
    function  Start_ADC(): boolean;                             // ������ ���
    procedure Stop_ADC();                                       // ���� ���
    function LengthControlTable: WORD;                          // ���������� ����� ����������� �������
    function GetScaleOfChannel(Ch: WORD): double;               // ���������� ����� �� ������ � �������
    function IsReady: boolean;                                  // ���������� �����
    procedure SetStateDigitalOutputRegisters(OnOff: Boolean);            // ���������/���������� �������� ���������
    procedure Out(Value: Integer);                              //�������� � �������� ������� ��������
    function Input():Integer;                                      //��������� �� ��������� �������� ��������
    //    property IsReady: boolean read Status;
    property RateAdc: double read AdcRate write AdcRate;        // ������ ������ ���
    property RateKadr: double read KadrRate;                    // ������� ������
    property DuratoinSignal: WORD read Duration write Duration; // ������������ ����������� �������
    property AdcDataArray: TAdcDataOfChannel read AdcData;      // ������ ������ �� ���� ������� ���
    property UsbSpeedTxt: String read StrUsbSpeed;
  end;

implementation

{ TPlata }

procedure TPlata.AbortProgram(ErrorString: string; AbortionFlag: boolean);
begin
  // ������ ����� "�� ������"
  //Status := false;

	// ��������� ��������� ������
	if pModule <> nil then
	begin
	  // ��������� ��������� ������
		if pModule.ReleaseLInstance() then
      // ������� ��������� �� ��������� ������
			pModule := nil;
  end;

	// ��������� ������ ��-��� ������� ������
	AdcBuffer := nil;
  AdcData := nil;
  ControlTable := nil;

	// ���� ����� - ������� ��������� � �������
	if ErrorString <> '' then
    MessageBox(HWND(nil), pCHAR(ErrorString), '������!', MB_OK + MB_ICONERROR);
	// ���� ����� - �������� ��������� ���������
	if AbortionFlag then
    Application.Terminate;
end;

procedure TPlata.AddChannel(Channel: TLogicalCnannel);
begin
  SetLength(ControlTable, Length(ControlTable) + 1);
  ControlTable[Length(ControlTable) - 1] := Channel;
end;

procedure TPlata.ClearControlTable;
begin
  SetLength(ControlTable, 0);
end;

destructor TPlata.Destroy;
begin
  inherited Destroy;
  AbortProgram('');
end;

procedure TPlata.Fill_ADC_PARS_2010;
var
  i, j: integer;
  k: WORD;
  Exponent: WORD;
  s: String;
begin
  if not IsReady then
    exit;
	// ��������� �������� ��������� ����� ������ � ������ E20-10
	if ModuleDescription.Module.Revision = BYTE(REVISIONS_E2010[REVISION_A_E2010]) then
		ap.IsAdcCorrectionEnabled := FALSE				// �������� �������������� ������������� ������ �� ������ ������ (��� Rev.A)
	else
  begin
		ap.IsAdcCorrectionEnabled := TRUE; 				// �������� �������������� ������������� ������ �� ������ ������ (��� Rev.B � ����)
		ap.SynchroPars.StartDelay := 0;
		ap.SynchroPars.StopAfterNKadrs := 0;
		ap.SynchroPars.SynchroAdMode := NO_ANALOG_SYNCHRO_E2010;
//		ap.SynchroPars.SynchroAdMode := ANALOG_SYNCHRO_ON_HIGH_LEVEL_E2010;
		ap.SynchroPars.SynchroAdChannel := $0;
		ap.SynchroPars.SynchroAdPorog := 0;
		ap.SynchroPars.IsBlockDataMarkerEnabled := $0;
	end;
	ap.SynchroPars.StartSource := INT_ADC_START_E2010;			// ���������� ����� ����� � ���
	ap.SynchroPars.SynhroSource := INT_ADC_CLOCK_E2010;			// ���������� �������� �������� ���
//	ap.OverloadMode := MARKER_OVERLOAD_E2010;			// �������� ����� ���������� ������� ������� ��� ������ �������� � ������� ��� (������ ��� Rev.A)
 	ap.OverloadMode := CLIPPING_OVERLOAD_E2010;		  // ������� �������� ����� ���������� ������� ������� ���� ����������� ������� ��� (������ ��� Rev.A)

  // ������������ ������� �����������
  for i:=0 to (ADC_CHANNELS_QUANTITY_E2010-1) do
  begin
	  ap.InputRange[i] := ADC_INPUT_RANGE_3000mV_E2010; 	// ������� �������� 3�
		ap.InputSwitch[i] := ADC_INPUT_ZERO_E2010;			    // �������� ����� - ���������� ����� ������.
  end;

  // ���-�� �������� ������� (������ �����)
  k := 0;
  for i := 0 to Length(ControlTable) - 1 do
  begin
    k := k + ControlTable[i].Repeating;
  end;
  // ���� ���-�� ���������� ������� ������ ��������������, �� ��������� �� ���������
  if k >= MAX_CONTROL_TABLE_LENGTH_E2010 then
  begin
    k := 256;
    MessageBox(HWND(Nil), '��������� ������������ ���������� ���������� ������� � ����������� �������! ����������� 256',
      '��������!', MB_OK + MB_ICONWARNING);
  end;

  ap.ChannelsQuantity := k; // ��������� � ���-�� ���-�� �������� ������� (������ �����)

  // �������� ����������� ������� ��� �� �������������� ����������� �������
  k := 0;
  for i := 0 to Length(ControlTable) - 1 do
    for j := 0 to ControlTable[i].Repeating - 1 do
    begin
      ap.ControlTable[k] := ControlTable[i].Number - 1; //����� ������
      // ���������� ������� �����
      ap.InputRange[ControlTable[i].Number - 1] := ControlTable[i].InputRange; 	 // ������� ��������
      ap.InputSwitch[ControlTable[i].Number - 1] := ControlTable[i].InputSwitch; // �������� ����� 
      k := k + 1;
	  end;

	ap.AdcRate := AdcRate;		 	  // ������� ��� ������ � ���
  ap.InterKadrDelay := 0.0;	   	// ����������� �������� � ��; (���������� ��������� 1/AdcRate)

	// ������� � ��������� ���������� ������ ��� ���������������� ������������ ���
 	for i := 0 to (ADC_INPUT_RANGES_QUANTITY_E2010 - 1) do
		for j := 0 to (ADC_CHANNELS_QUANTITY_E2010 - 1) do
		begin
			// ������������� ��������
 			ap.AdcOffsetCoefs[i][j] := ModuleDescription.Adc.OffsetCalibration[j + i * ADC_CHANNELS_QUANTITY_E2010];
			// ������������� ��������
 			ap.AdcScaleCoefs[i][j] := ModuleDescription.Adc.ScaleCalibration[j + i * ADC_CHANNELS_QUANTITY_E2010];
		end;

	// ��������� � ������ ��������� ��������� �� ����� ������
	if not pModule.SET_ADC_PARS(@ap) then
  begin
    AbortProgram('�� ���� ���������� ��������� ����� ������!');
    exit;
  end;

   // ������� ������� ��������� ������ ����� ������
 	if not pModule.GET_ADC_PARS(@ap) then
  begin
    AbortProgram('�� ���� �������� ������� ��������� ����� ������!');
    exit;
  end;     
  // ������� ��������� ������ ��������� ����������
  AdcRate := ap.AdcRate;
  KadrRate := ap.KadrRate;
  KadrDelay := ap.InterKadrDelay;

  //��������� ����� ����� �������
  if not pModule.STOP_ADC then
  begin
    AbortProgram('�� ���� �������� "����" ����� ��������!');
    exit;
  end;

  // ���������� ����������� ���-�� �������� ��� ��� ������ ������� ������������� t ��
  DataStep := Round((Duration / (1 / KadrRate))) * ap.ChannelsQuantity;
  Exponent := Round(Log2(Duration / (1 / KadrRate)* ap.ChannelsQuantity));
  if not (Power(2, Exponent) >= DataStep) then
    DataStep := round(Power(2, Exponent) * 2)
  else
    DataStep := round((Power(2, Exponent)));

  if not (DataStep <= 1024*1024) then
  begin
    s := '��� ����������� ������� ������� ����� �������� ���' + #13 +
      '������� ����� ����� �� �������� �� ��������� ������������' + #13 +
      '� ���������� ���������� ������� ������� ��� ��� ��������� ������������ �������.';
    MessageBox(HWND(nil), Pchar(s) , '��������������', MB_OK + MB_ICONWARNING);
  end;

  // ��������� �������� ������ ���-�� ������ ��� ����� ������
  AdcBuffer := nil;
  SetLength(AdcBuffer, DataStep);

  // ��������� ��������� IoReq
  IoReq.Buffer := Pointer(AdcBuffer);			// ����� ������
	IoReq.NumberOfWordsToPass := DataStep;	// ���-�� ���������� ������
 	IoReq.NumberOfWordsPassed := 0;
	IoReq.Overlapped := nil;					      // ���������� ������� �������
	IoReq.TimeOut := Round(int(DataStep/ap.KadrRate)) + 1000;	// ������� ����������� ����� ������

end;


function TPlata.GetScaleOfChannel(Ch: WORD): double;
var
  Scale: WORD;

begin
  Result := 0;
  if not IsReady then
  begin
    AbortProgram('�� ���� �������� �������');
    exit;
  end;

  if (Ch >= 0) and (Ch <= 3) then
  begin
    Scale := ap.InputRange[Ch];
    case Scale of
      0: Result := 3;
      1: Result := 1;
      2: Result := 0.3;
    end;
  end;
end;

function TPlata.Input: Integer;
var
  Buffer: pWORD;
begin
  Result := 0;
  if IsReady then
  begin
    pModule.TTL_IN(Buffer);
    Result := Buffer^;
  end;
end;

function TPlata.IsReady: boolean;
begin
  if pModule = nil then
    Result := False
  else
    Result := True;
end;

function TPlata.LengthControlTable: WORD;
begin
  Result := Length(ControlTable);
end;

procedure TPlata.Out(Value: Integer);
begin
  if IsReady then
    pModule.TTL_OUT(Value);
end;

procedure TPlata.ParseData;
var
  i: DWORD;
  j, k: integer;
  CurTime, t, d: double;
  QuantityKadr: DWORD;
  Scale: double;
begin
  AdcData := nil;
  SetLength(AdcData, ADC_CHANNELS_QUANTITY_E2010);

  t := 1 /(AdcRate*1000);
  d := KadrDelay /1000;
  Scale := 0;

  i := 0; // ������ ��������
  CurTime := 0; //������� �����
  QuantityKadr := trunc(DataStep / ap.ChannelsQuantity);     //���-�� ������
  for k := 0 to QuantityKadr - 1 do
  begin
    for j := 0 to ap.ChannelsQuantity - 1 do   //���-�� ��������� �������
    begin
      SetLength(AdcData[ap.ControlTable[j]], Length(AdcData[ap.ControlTable[j]]) + 1);
      AdcData[ap.ControlTable[j]][Length(AdcData[ap.ControlTable[j]])-1].quantization_step := TShortrArray(IoReq.Buffer)[i]; // ��������
      case ap.InputRange[ap.ControlTable[j]] of
        0: Scale := 3;
        1: Scale := 1;
        2: Scale := 0.3;
      end;
      AdcData[ap.ControlTable[j]][Length(AdcData[ap.ControlTable[j]])-1].voltage := TShortrArray(IoReq.Buffer)[i]/8192 * Scale;    // ������
      AdcData[ap.ControlTable[j]][Length(AdcData[ap.ControlTable[j]])-1].time := CurTime;     // �����
      CurTime := CurTime + t;
      inc(i);
    end;
    CurTime := CurTime + d - t;
  end;
end;

constructor TPlata.PlataCreate();
var
  Str: String;
  i: integer;
begin
  inherited Create;

  //������� ������ ���������� �����
  //Status := true;

  DataStep := 1024;
  AdcRate := 1000; // 1 ���
  Duration := 13;  // 13 ��
  ControlTable := nil;

  // �������� ������ ������������ DLL ����������
	DllVersion := GetDllVersion;
	if DllVersion <> CURRENT_VERSION_LUSBAPI then
  begin
	  Str := '�������� ������ DLL ���������� Lusbapi.dll! ' + #10#13 +
		  ' �������: ' + IntToStr(DllVersion shr 16) +  '.' +
      IntToStr(DllVersion and $FFFF) + '.' +  ' ���������: ' +
      IntToStr(CURRENT_VERSION_LUSBAPI shr 16) + '.' +
      IntToStr(CURRENT_VERSION_LUSBAPI and $FFFF) + '.';
			AbortProgram(Str);
    exit;
  end;

	// ��������� �������� ��������� �� ��������� ��� ������ E20-10
	pModule := CreateLInstance(pCHAR('e2010'));
	if pModule = nil then
  begin
    AbortProgram('�� ���� ����� ��������� ������ E20-10!');
    exit;
  end;

  // ��������� ���������� ������ E20-10 � ������ MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI ����������� ������
	for i := 0 to (MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI-1) do
    if pModule.OpenLDevice(i) then
      break;

	// ���-������ ����������?
	if i = MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI then
  begin
    AbortProgram('�� ������� ���������� ������ E20-10 � ������ 127 ����������� ������!');
    exit;
  end;

	// ������� ������������� ����������
	ModuleHandle := pModule.GetModuleHandle();

	// ��������� �������� ������ � ������� ����������� �����
	ModuleName := '123456';
	if not pModule.GetModuleName(pCHAR(ModuleName)) then
  begin
    AbortProgram('�� ���� ��������� �������� ������!');
    exit;
  end;

	// ��������, ��� ��� ������ E20-10
	if Boolean(AnsiCompareStr(ModuleName, 'E20-10')) then
  begin
    AbortProgram('������������ ������ �� �������� E20-10!');
    exit;
  end;

	// ��������� �������� �������� ������ ���� USB
  if not pModule.GetUsbSpeed(@UsbSpeed) then
  begin
    AbortProgram(' �� ���� ���������� �������� ������ ���� USB');
    exit;
  end;

	// ������ �������� �������� ������ ���� USB
	if UsbSpeed = USB11_LUSBAPI then
    StrUsbSpeed := 'USB Full-Speed Mode (12 Mbit/s)'
  else
    StrUsbSpeed := 'USB High-Speed Mode (480 Mbit/s)';


	// ����� ��� ���� ������ �� ���������������� ������� DLL ���������� Lusbapi.dll
	if not pModule.LOAD_MODULE(nil) then
  begin
    AbortProgram('�� ���� ��������� ������ E20-10!');
    exit;
  end;

	// �������� �������� ������
 	if not pModule.TEST_MODULE() then
  begin
    AbortProgram('������ � �������� ������ E20-10!');
    exit;
  end;

	// ������ ������� ����� ������ ������������ �������� DSP
	if not pModule.GET_MODULE_DESCRIPTION(@ModuleDescription) then
  begin
    AbortProgram('�� ���� �������� ���������� � ������!');
    exit;
  end;

	// ��������� ��������� ���������� ����������������� ����
	if not pModule.READ_FLASH_ARRAY(@UserFlash) then
  begin
    AbortProgram('�� ���� ��������� ���������������� ����!');
    exit;
  end;

  SetStateDigitalOutputRegisters(True);

end;

procedure TPlata.SetStateDigitalOutputRegisters(OnOff: Boolean);
begin
  if IsReady then
    pModule.ENABLE_TTL_OUT(OnOff);
end;

function TPlata.Start_ADC;
begin
  Result := False;
  if not IsReady then
    exit;

  // �������� ���
	if not pModule.START_ADC() then
  begin
    AbortProgram('�� ���� �������� "�����"!');
    exit;
  end;

	// ���������� ������ ������ �� ���� ������
	if not pModule.ReadData(@IoReq) then
  begin
    Stop_ADC;
    AbortProgram('�� ���� ��������� ������ �� ������ ������');
    exit;
  end;

  //������� ������, ������ ����
  Stop_ADC;

  // ����� �������� �������� ������
  ParseData;

  Result := True;
end;

procedure TPlata.Stop_ADC;
begin
  if not pModule.STOP_ADC then
  begin
    AbortProgram('�� ���� �������� "����"!');
    exit;
  end;

  // ������ �������� ������������� ����������� ������ �� ���� ������
	if not CancelIo(ModuleHandle) then
  begin
    AbortProgram('������ ��������� �������������� ������� �� ����� ������');
    exit;
  end;
end;

end.
