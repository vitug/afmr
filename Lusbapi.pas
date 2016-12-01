// *****************************************************************************
// �������� ���� c ������������ ��������, ��������, ������� � �.�. ��� ������
// � �������� ������������ �������� ��� "L-Kard" � ����� Borland Delphi 6.0.
// �������������� ������: E14-140, E14-440 � E20-10.
// *****************************************************************************

unit Lusbapi;

interface

uses
	windows;

// ����� ���������
const
	NAME_LINE_LENGTH_LUSBAPI				=	25;
	COMMENT_LINE_LENGTH_LUSBAPI			=	256;
	ADC_CALIBR_COEFS_QUANTITY_LUSBAPI	=	128;
	DAC_CALIBR_COEFS_QUANTITY_LUSBAPI	=	128;

// ����� ��������� � ���� ������
type
	pBYTE			= ^BYTE;
	pSHORT		= ^SHORT;
	pWORD			= ^WORD;
	pDWORD		= ^DWORD;
	pOVERLAPPED = ^OVERLAPPED;

	// ���������, ���������� ���������� � ������ �������� DSP
	IO_REQUEST_LUSBAPI = packed record
		Buffer : pSHORT;			 							//	��������� �� ����� ������
		NumberOfWordsToPass : DWORD;			 			// ���-�� ��������, ������� ��������� ��������
		NumberOfWordsPassed : DWORD;						// �������� ���-�� ���������� ��������
		Overlapped : pOVERLAPPED;							// ��� ������������� ������� - ��������� �� ��������� ���� OVERLAPPED
		TimeOut : DWORD;										// ��� ����������� ������� - ������� � ��
	end;
	pIO_REQUEST_LUSBAPI = ^IO_REQUEST_LUSBAPI;

	// ��������� � ����������� �� ��������� ������ ���������� ����������
	LAST_ERROR_INFO_LUSBAPI = packed record
		ErrorString : array [0..255] of BYTE;			// ������ � ��������� �������
		ErrorNumber : DWORD;	  								// ����� ��������� ������
	end;
	pLAST_ERROR_INFO_LUSBAPI = ^LAST_ERROR_INFO_LUSBAPI;

	// ���������� � ��, ���������� � ��������������� ����������: MCU, DSP, PLD � �.�.
	VERSION_INFO_LUSBAPI = packed record
		Version : array [0..9] of BYTE;				  	// ������ �� ��� ���������������� ����������
		Date : array [0..13] of BYTE;					  	// ���� ������ ��
		Manufacturer : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;	// ������������� ��
		Author : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;	  		// ����� ��
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � �� MCU, ������� �������� � ���� ���������� � ���������
	// ��� �������� ���������, ��� � ����������
	MCU_VERSION_INFO_LUSBAPI = packed record
		FwVersion : VERSION_INFO_LUSBAPI;				// ���������� � ������ �������� �������� ��������� '����������'(Application) ����������������
		BlVersion : VERSION_INFO_LUSBAPI;				// ���������� � ������ �������� '����������'(BootLoader) ����������������
	end;

	// ����� ���������� � ������
	MODULE_INFO_LUSBAPI = packed record
		CompanyName : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// �������� �����-������������ �������
		DeviceName : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE; 		// �������� �������
		SerialNumber : array [0..15] of BYTE;			// �������� ����� �������
		Revision : BYTE;										// ������� �������
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � DSP
	DSP_INFO_LUSBAPI = packed record
		Active : BOOL;											// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;				// �������� DSP
		ClockRate : double;									// �������� ������� ������ DSP � ���
		Version : VERSION_INFO_LUSBAPI;					// ���������� � �������� DSP
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ���������������� (��� '����������')
	MCU_INFO_LUSBAPI = packed record
		Active : BOOL;										  	// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;				// �������� ����������������
		ClockRate : double;								  	// �������� ������� ������ ���������������� � ���
		Version : VERSION_INFO_LUSBAPI;				  	// ���������� � ������ �������� ����������������
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ���������������� (������� '���������')
	MCU1_INFO_LUSBAPI = packed record
		Active : BOOL;										  	// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;				// �������� ����������������
		ClockRate : double;								  	// �������� ������� ������ ���������������� � ���
		Version : MCU_VERSION_INFO_LUSBAPI;		 	  	// ���������� � ������ ��� ����� �������� ����������������, ��� � �������� '����������'
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ���� (PLD)
	PLD_INFO_LUSBAPI = packed record				 		// PLD - Programmable Logic Device
		Active : BOOL;									 		// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;		  		// �������� ����
		ClockRate : double;							 		// �������� ������ ������ ���� � ���
		Version : VERSION_INFO_LUSBAPI;			  		// ���������� � ������ �������� ����
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ���
	ADC_INFO_LUSBAPI = packed record
		Active : BOOL;									 		// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;				// �������� ���������� ���
		OffsetCalibration : array [0..(ADC_CALIBR_COEFS_QUANTITY_LUSBAPI-1)] of double;	// ���������������� ������������ �������� ����
		ScaleCalibration : array [0..(ADC_CALIBR_COEFS_QUANTITY_LUSBAPI-1)] of double; 	// ���������������� ������������ ��������
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ���
	DAC_INFO_LUSBAPI = packed record
		Active : BOOL;									 		// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;				// �������� ���������� ���
		OffsetCalibration : array [0..(DAC_CALIBR_COEFS_QUANTITY_LUSBAPI-1)] of double;	// ���������������� ������������
		ScaleCalibration : array [0..(DAC_CALIBR_COEFS_QUANTITY_LUSBAPI-1)] of double;  	// ���������������� ������������
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ��������� �����-������
	DIGITAL_IO_INFO_LUSBAPI = packed record
		Active : BOOL;											// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;				// �������� �������� ����������
		InLinesQuantity : WORD;	 							// ���-�� ������� �����
		OutLinesQuantity : WORD; 							// ���-�� �������� �����
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

	// ���������� � ������������� ���������� ��� ������� � ������
	INTERFACE_INFO_LUSBAPI = packed record
		Active : BOOL;										 	// ���� ������������� ��������� ����� ���������
		Name : array [0..(NAME_LINE_LENGTH_LUSBAPI-1)] of BYTE;			 	// ��������
		Comment : array [0..(COMMENT_LINE_LENGTH_LUSBAPI-1)] of BYTE;		// ������ �����������
	end;

// ���������� ���������� Lusbbase
{$I 'Lusbbase.pas'}
// ���������� ���������� ��� ������ E14-140
{$I 'E140.pas'}
// ���������� ���������� ��� ������ E-154
{$I 'E154.pas'}
// ���������� ���������� ��� ������ E14-440
{$I 'E440.pas'}
// ���������� ���������� ��� ������ E20-10
{$I 'E2010.pas'}

const
	// ������� ������ ������� ���������� Lusbapi.dll
	VERSION_MAJOR_LUSBAPI 			=	($03);
	VERSION_MINOR_LUSBAPI 			=	($02);
	CURRENT_VERSION_LUSBAPI			=	((VERSION_MAJOR_LUSBAPI shl 16) or VERSION_MINOR_LUSBAPI);

	// ��������� ������� �������� ������ ������ �� ���� USB
	USB11_LUSBAPI						=	($00);
	USB20_LUSBAPI						=	($01);
	INVALID_USB_SPEED_LUSBAPI		=	($02);

	// ����������� ��������� ���-�� ������������ ����������� ������
	MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI	= 127;

// ���������� �������������� �� Lusbapi.dll �������
Function GetDllVersion : DWORD; stdcall;
Function CreateLInstance(DeviceName : PChar) : Pointer; stdcall;

implementation
	Function GetDllVersion : DWORD; External 'Lusbapi.dll'
	Function CreateLInstance(DeviceName : PChar) : Pointer; External 'Lusbapi.dll'
end.
