// *****************************************************************************
// ******************  � � � � � �    E 2 0 - 1 0  *****************************
// *****************************************************************************

// ���������
const
	// ������� ��������� ���������� �������� ������ ����� ������
	INT_ADC_START_E2010							=	($00);
	INT_ADC_START_WITH_TRANS_E2010			=	($01);
	EXT_ADC_START_ON_RISING_EDGE_E2010	 	=	($02);
	EXT_ADC_START_ON_FALLING_EDGE_E2010		=	($03);
	INVALID_ADC_START_E2010						=	($04);

	// ������� ��������� ���������� �������� ��������� ��� ���
	INT_ADC_CLOCK_E2010							=	($00);
	INT_ADC_CLOCK_WITH_TRANS_E2010			=	($01);
	EXT_ADC_CLOCK_ON_RISING_EDGE_E2010	 	=	($02);
	EXT_ADC_CLOCK_ON_FALLING_EDGE_E2010		=	($03);
	INVALID_ADC_CLOCK_E2010						=	($04);

	// ��������� ���� ���������� ������������� ����� ������ (��� Rev.B � ����)
	NO_ANALOG_SYNCHRO_E2010					 		=	($00); 	// ���������� ���������� �������������
	ANALOG_SYNCHRO_ON_RISING_CROSSING_E2010	=	($01);	// ���������� ������������� �� �������� �����-�����
   ANALOG_SYNCHRO_ON_FALLING_CROSSING_E2010	=	($02);	// ���������� ������������� �� �������� ������-����
	ANALOG_SYNCHRO_ON_HIGH_LEVEL_E2010			=	($03);	// ���������� ������������� �� ������ ����
   ANALOG_SYNCHRO_ON_LOW_LEVEL_E2010			=	($04);	// ���������� ������������� �� ������ ����
	INVALID_ANALOG_SYNCHRO_E2010					=	($05);

	// ������� ��������� ���������� �������� ���������� ������ E20-10
	ADC_INPUT_RANGE_3000mV_E2010				=	($00);
	ADC_INPUT_RANGE_1000mV_E2010				=	($01);
	ADC_INPUT_RANGE_300mV_E2010				=	($02);
	INVALID_ADC_INPUT_RANGE_E2010				=	($03);

	// ������� ��������� ����� ����������� �������� ������ ������ E20-10
	ADC_INPUT_ZERO_E2010							=	($00);
	ADC_INPUT_SIGNAL_E2010					 	=	($01);
	INVALID_ADC_INPUT_E2010						=	($02);

	// ��������� ������� ��� ���������� ������� ����� �������� ������ E20-10 (��� Rev.B � ����)
	INPUT_CURRENT_OFF_E2010						=	($00);
	INPUT_CURRENT_ON_E2010						=	($01);
	INVALID_INPUT_CURRENT_E2010				=	($02);

	// ��������� ������ �������� ����� ���������� ������� ������� ��� ����� ������ (������ ��� Rev.A)
	CLIPPING_OVERLOAD_E2010		 				=	($00);
   MARKER_OVERLOAD_E2010		 				=	($01);
   INVALID_OVERLOAD_E2010		 				=	($02);

	// ��������� ������ ����� ������ ��� ���������� ����� ������ � ���
		// ���� BufferOverrun ��������� DATA_STATE_E2010
		BUFFER_OVERRUN_E2010	 					=	($00);	// ������������ ����������� ������ ������
		// ���� ChannelsOverFlow ��������� DATA_STATE_E2010
		OVERFLOW_OF_CHANNEL_1_E2010	 		=	($00);	// ��������� �������� ������������
	   OVERFLOW_OF_CHANNEL_2_E2010			=	($01);	// ��������� ����� ���������������� ������
	   OVERFLOW_OF_CHANNEL_3_E2010	 		=	($03);	// �� ����� ���������� ������ �������
	   OVERFLOW_OF_CHANNEL_4_E2010	 		=	($04);	// ����� ������ ReadData()
		OVERFLOW_E2010	 							=	($07);	// ���������� ������� ����� ������������ ��������� �����
																		// ������ �� �� ����� ����� ������ �� ������� START_ADC() �� STOP_ADC()

	// ��������� ��������� ��� ������� �������� ������� ������ ������ E20-10 (��� Rev.B � ����)
	// ������������ � ������� TEST_MODULE()   
	NO_TEST_MODE_E2010	 						=	($00); 	// �� ������������� ������� �������� �������
   TEST_MODE_1_E2010		 						=	($01); 	// �������� �����, ��� ������� ����� START_ADC() ������ � ���
																		// ����������� ������� ����������� �����: 0, 1, 2, 3, ...

	// ������� ��������� ����� ������� ���������� ���
	DAC_INACCESSIBLED_E2010						=	($00);
	DAC_ACCESSIBLED_E2010						=	($01);
	INVALID_DAC_OPTION_E2010					=	($02);

	// ������� ��������� ������� ������ E20-10
	REVISION_A_E2010								=	($00);
	REVISION_B_E2010								=	($01);
	INVALID_REVISION_E2010						=	($02);

	// ��������� ��� ������ � �������
	MAX_CONTROL_TABLE_LENGTH_E2010 			=	(256);
	ADC_CHANNELS_QUANTITY_E2010				=	($04);
	ADC_INPUT_RANGES_QUANTITY_E2010			=	(INVALID_ADC_INPUT_RANGE_E2010);
	ADC_INPUT_TYPES_QUANTITY_E2010			=	(INVALID_ADC_INPUT_E2010);
	ADC_CALIBR_COEFS_QUANTITY_E2010			=	(ADC_CHANNELS_QUANTITY_E2010 * ADC_INPUT_RANGES_QUANTITY_E2010);
	DAC_CHANNELS_QUANTITY_E2010				=	($02);
	DAC_CALIBR_COEFS_QUANTITY_E2010			=	(DAC_CHANNELS_QUANTITY_E2010);
	TTL_LINES_QUANTITY_E2010					=	($10);	// ���-�� ������� � �������� �������� �����
	USER_FLASH_SIZE_E2010 						=	($200);	// ������ ������� ����������������� ���� � ������
	REVISIONS_QUANTITY_E2010 					=	(INVALID_REVISION_E2010);	// ���-�� ������� (�����������) ������
	ADC_PLUS_OVERLOAD_MARKER_E2010			=	($5FFF);	// ������� '����' ���������� ������� � ��� (������ ��� Rev.A)
	ADC_MINUS_OVERLOAD_MARKER_E2010			=	($A000);	// ������� '�����' ���������� ������� � ��� (������ ��� Rev.A)

	// ��������� �������� ���������� ��� � �
	ADC_INPUT_RANGES_E2010 : array [0..(ADC_INPUT_RANGES_QUANTITY_E2010-1)]  of double =	( 3.0, 1.0, 0.3 );
	// ��������� ��������� ���������� ��� � �
	DAC_OUTPUT_RANGE_E2010	  					=	5.0;
	// ��������� ������� ������
	REVISIONS_E2010 : array [0..(REVISIONS_QUANTITY_E2010-1)] of char = ( 'A', 'B' );


// ����
type
	// ��������� � ����������� �� ������ E20-10
	MODULE_DESCRIPTION_E2010 = packed record
		Module 		: MODULE_INFO_LUSBAPI;		  	// ����� ���������� � ������
		DevInterface	: INTERFACE_INFO_LUSBAPI;	// ���������� �� ������������ ����������� ����������
		Mcu			: MCU1_INFO_LUSBAPI;				// ���������� � ���������������� (������� '���������')
		Pld			: PLD_INFO_LUSBAPI;				// ���������� � ����
		Adc			: ADC_INFO_LUSBAPI;				// ���������� � ���
		Dac			: DAC_INFO_LUSBAPI;				// ���������� � ���
		DigitalIo	: DIGITAL_IO_INFO_LUSBAPI;		// ���������� � �������� �����-������
	end;
	pMODULE_DESCRIPTION_E2010 = ^MODULE_DESCRIPTION_E2010;

	// ��������� ����������������� ����
	USER_FLASH_E2010 = packed record
		Buffer : array [0..(USER_FLASH_SIZE_E2010-1)] of BYTE;
	end;
	pUSER_FLASH_E2010 = ^USER_FLASH_E2010;

	// ��������� � ����������� ������������� ����� ������ � ���
	SYNCHRO_PARS_E2010 = packed record
		StartSource		: WORD;				  	// ��� � �������� ������� ������ ����� ������ � ��� (���������� ��� ������� � �.�.)
		StartDelay		: DWORD;					// �������� ������ ����� ������ � ������ �������� c ��� (��� Rev.B � ����)
		SynhroSource	: WORD;					// �������� �������� ��������� ������� ��� (���������� ��� ������� � �.�.)
		StopAfterNKadrs: DWORD;					// ������� ����� ������ ����� ����������� ����� ���-�� ��������� ������ �������� ��� (��� Rev.B � ����)
		SynchroAdMode	: WORD;   				// ����� ���������� ������������: ������� ��� ������� (��� Rev.B � ����)
		SynchroAdChannel	: WORD;				// ���������� ����� ��� ��� ���������� ������������� (��� Rev.B � ����)
		SynchroAdPorog		: SHORT;				// ����� ������������ ��� ���������� ������������� (��� Rev.B � ����)
		IsBlockDataMarkerEnabled : BYTE;		// ������������ ������ ����� ������ (������, ��������, ��� ���������� ������������� ����� �� ������) (��� Rev.B � ����)
	end;

	// ��������� ���������� ������ ��� ��� ������ E20-10
	ADC_PARS_E2010 = packed record
		IsAdcCorrectionEnabled : BOOL;		// ���������� ����������� �������������� �������������� ���������� ������ �� ������ ������ (��� Rev.B � ����)
		OverloadMode : WORD;	  					// ����� �������� ����� ���������� ������� ������� ������ (������ ��� Rev.A)
		InputCurrentControl: WORD;				// ���������� ������� ����� �������� (��� Rev.B � ����)
		SynchroPars : SYNCHRO_PARS_E2010;	// ��������� ������������� ����� ������ � ���
		ChannelsQuantity : WORD; 		// ����� �������� ���������� �������
		ControlTable : array [0..(MAX_CONTROL_TABLE_LENGTH_E2010-1)] of WORD;	// ����������� ������� � ��������� ����������� ��������
		InputRange : array [0..(ADC_CHANNELS_QUANTITY_E2010-1)] of WORD;	// ������ ��������� �������� ����������: 3.0�, 1.0� ��� 0.3�
		InputSwitch : array [0..(ADC_CHANNELS_QUANTITY_E2010-1)] of WORD;	// ������ ���� ����� ������ ���: ����� ��� ������
		AdcRate : double;	  		 		// �������� ������� ��� � ���
		InterKadrDelay : double; 		// ����������� �������� � ��
		KadrRate : double;		 		// ������� ����� � ���
		AdcOffsetCoefs : array [0..(ADC_INPUT_RANGES_QUANTITY_E2010-1)] of array[0..(ADC_CHANNELS_QUANTITY_E2010-1)] of double;	// ���������������� ������������ ��������	���: (3 ���������)*(4 ������) (��� Rev.B � ����)
		AdcScaleCoefs	: array [0..(ADC_INPUT_RANGES_QUANTITY_E2010-1)] of array[0..(ADC_CHANNELS_QUANTITY_E2010-1)] of double;	// ���������������� ������������ �������� ���: (3 ���������)*(4 ������) (��� Rev.B � ����)
	end;
	pADC_PARS_E2010 = ^ADC_PARS_E2010;

	// ��������� � ����������� � ������� ��������� �������� ����� ������
	DATA_STATE_E2010 = packed record
		ChannelsOverFlow : BYTE;				// ������� �������� ���������� ������� ���������� ������� ������ ��� Rev.B � ����
		BufferOverrun : BYTE;					// ������� �������� ������������ ����������� ������ ������
		CurBufferFilling : DWORD;				// ������������� ����������� ������ ������ ��� Rev.B � ����, � ��������
		MaxOfBufferFilling : DWORD;			// �� ����� ����� ������������ ������������� ����������� ������ ������ ��� Rev.B � ����, � ��������
		BufferSize : DWORD;						// ������ ����������� ������ ������ ��� Rev.B � ����, � ��������
		CurBufferFillingPercent : double;	// ������� ������� ���������� ����������� ������ ������ ��� Rev.B � ����, � %
		MaxOfBufferFillingPercent : double;	// �� �� ����� ����� ������������ ������� ���������� ����������� ������ ������ ��� Rev.B � ����, � %
	end;
	pDATA_STATE_E2010 = ^DATA_STATE_E2010;

// ��������� ������ E20-10
ILE2010 = class(Lusbbase)
  public
		// �������� ���� ������
		Function LOAD_MODULE(FileName : pCHAR = nil) : BOOL; virtual; stdcall; abstract;
		Function TEST_MODULE(TestModeMask : WORD = 0) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���
		Function GET_ADC_PARS(ap : pADC_PARS_E2010) : BOOL; virtual; stdcall; abstract;
		Function SET_ADC_PARS(ap : pADC_PARS_E2010) : BOOL; virtual; stdcall; abstract;
		Function START_ADC : BOOL; virtual; stdcall; abstract;
		Function STOP_ADC : BOOL; virtual; stdcall; abstract;
		Function GET_DATA_STATE(DataState : pDATA_STATE_E2010) : BOOL; virtual; stdcall; abstract;
		Function ReadData(ReadRequest : pIO_REQUEST_LUSBAPI) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���
		Function DAC_SAMPLE(DacData : pSHORT; DacChannel : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ��������� �������
		Function ENABLE_TTL_OUT(EnableTtlOut : BOOL) : BOOL; virtual; stdcall; abstract;
		Function TTL_IN(TtlIn : pWORD) : BOOL; virtual; stdcall; abstract;
		Function TTL_OUT(TtlOut : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���������������� ����������� ����
		Function ENABLE_FLASH_WRITE(IsUserFlashWriteEnabled : BOOL) : BOOL; virtual; stdcall; abstract;
		Function READ_FLASH_ARRAY(UserFlash : pUSER_FLASH_E2010) : BOOL; virtual; stdcall; abstract;
		Function WRITE_FLASH_ARRAY(UserFlash : pUSER_FLASH_E2010) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ �� ��������� ����������� �� ����
		Function GET_MODULE_DESCRIPTION(ModuleDescription : pMODULE_DESCRIPTION_E2010) : BOOL; virtual; stdcall; abstract;
		Function SAVE_MODULE_DESCRIPTION(ModuleDescription : pMODULE_DESCRIPTION_E2010) : BOOL; virtual; stdcall; abstract;
	end;
	pILE2010 = ^ILE2010;

