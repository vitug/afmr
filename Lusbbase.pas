// *****************************************************************************
// ������ ���� ������� ��� USB ��������� �� L-Card
// *****************************************************************************

type
	Lusbbase = class
		// ������� ������ ���������� ��� ������ � USB ������������
		Function OpenLDevice(VirtualSlot : WORD) : BOOL; virtual; stdcall; abstract;
		Function CloseLDevice : BOOL; virtual; stdcall; abstract;
		Function ReleaseLInstance : BOOL; virtual; stdcall; abstract;
		// ��������� ����������� ���������� USB
		Function GetModuleHandle : THandle; virtual; stdcall; abstract;
		// ��������� �������� ������������� ������
		Function GetModuleName(ModuleName : pCHAR) : BOOL; virtual; stdcall; abstract;
		// ��������� ������� �������� ������ ���� USB
		Function GetUsbSpeed(UsbSpeed : pBYTE) : BOOL; virtual; stdcall; abstract;
		// ������� ������ ������ � ��������� �������
		Function GetLastErrorInfo(LastErrorInfo : pLAST_ERROR_INFO_LUSBAPI) : BOOL; virtual; stdcall; abstract;
	end;
