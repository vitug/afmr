// *****************************************************************************
// ******************  � � � � � �    E 1 4 - 1 4 0  ***************************
// *****************************************************************************

// ���������
const
	// ������� ��������� ���������� �������� ���������� ������ E14-440
	ADC_INPUT_RANGE_10000mV_E140			=	($00);
	ADC_INPUT_RANGE_2500mV_E140			=	($01);
	ADC_INPUT_RANGE_625mV_E140				=	($02);
	ADC_INPUT_RANGE_156mV_E140				=	($03);
	INVALID_ADC_INPUT_RANGE_E140			=	($04);

	// ������� ��������� ���������� �������� ��������� ��� ���
	INT_ADC_CLOCK_E140						=	($00);
	EXT_ADC_CLOCK_E140						=	($01);
	INVALID_ADC_CLOCK_E140				  	=	($02);

	// ��������� ������� ���������� ����������� �������� ��������� ���
	// �� ����� SYN �������� ��������� ������� (������ ��� ����������
	// ��������� �������� ��������� ���)
	ADC_CLOCK_TRANS_DISABLED_E140		  	=	($00);
	ADC_CLOCK_TRANS_ENABLED_E140		  	=	($01);
	INVALID_ADC_CLOCK_TRANS_E140		  	=	($02);

	// ������� ��������� ����� ������������� ������ E14-440
	NO_SYNC_E140								=	($00);
	TTL_START_SYNC_E140						=	($01);
	TTL_KADR_SYNC_E140						=	($02);
	ANALOG_SYNC_E140							=	($03);
	INVALID_SYNC_E140							=	($04);

	// ������� ��������� ����� ������� ���������� ���
	DAC_INACCESSIBLED_E140					=	($00);
	DAC_ACCESSIBLED_E140						=	($01);
	INVALID_DAC_OPTION_E140					=	($02);

	// ������� ��������� ������� ������ E14-440
	REVISION_A_E140 							=	($00);
	INVALID_REVISION_E140					=	($01);

	// ��������� ��� ������ � �������
	MAX_CONTROL_TABLE_LENGTH_E140			=	(128);
	ADC_INPUT_RANGES_QUANTITY_E140		=	(INVALID_ADC_INPUT_RANGE_E140);
	ADC_CALIBR_COEFS_QUANTITY_E140		=	(ADC_INPUT_RANGES_QUANTITY_E140);
	DAC_CHANNELS_QUANTITY_E140				=	($02);
	DAC_CALIBR_COEFS_QUANTITY_E140		=	(DAC_CHANNELS_QUANTITY_E140);
	TTL_LINES_QUANTITY_E140					=	($10);							// ���-�� �������� �����
	REVISIONS_QUANTITY_E140 				=	(INVALID_REVISION_E140);	// ���-�� ������� (�����������) ������

	// ��������� �������� ���������� ��� � �
	ADC_INPUT_RANGES_E140 : array [0..(ADC_INPUT_RANGES_QUANTITY_E140-1)]  of double =	( 10.0, 10.0/4.0, 10.0/16.0, 10.0/64.0 );
	// ��������� ��������� ���������� ��� � �
	DAC_OUTPUT_RANGE_E140					=	5.0;
	// ��������� ������� ������
	REVISIONS_E140 : array [0..(REVISIONS_QUANTITY_E140-1)] of char = ( 'A' );


// ����
type
	// ��������� � ����������� �� ������ E14-440
	MODULE_DESCRIPTION_E140 = packed record
		Module 		: MODULE_INFO_LUSBAPI;		  	// ����� ���������� � ������
		DevInterface	: INTERFACE_INFO_LUSBAPI;	// ���������� �� ������������ ����������� ����������
		Mcu			: MCU_INFO_LUSBAPI;				// ���������� � ����������������
		Adc			: ADC_INFO_LUSBAPI;				// ���������� � ���
		Dac			: DAC_INFO_LUSBAPI;				// ���������� � ���
		DigitalIo	: DIGITAL_IO_INFO_LUSBAPI;		// ���������� � �������� �����-������
	end;
	pMODULE_DESCRIPTION_E140 = ^MODULE_DESCRIPTION_E140;

	// ��������� ���������� ������ ��� ��� ������ E14-440
	ADC_PARS_E140 = packed record
		ClkSource : WORD;			  							// �������� �������� ��������� ��� ������� ���
		EnableClkOutput : WORD; 							// ���������� ���������� �������� ��������� ������� ���
		InputMode : WORD;										// ����� ����� ����� � ���
		SynchroAdType : WORD;								// ��� ���������� �������������
		SynchroAdMode : WORD; 								// ����� ���������� ������������
		SynchroAdChannel : WORD;  							// ����� ��� ��� ���������� �������������
		SynchroAdPorog : SHORT;								// ����� ������������ ��� ��� ���������� �������������
		ChannelsQuantity : WORD;							// ����� �������� ���������� �������
		ControlTable : array [0..(MAX_CONTROL_TABLE_LENGTH_E140-1)] of WORD;	// ����������� ������� � ��������� ����������� ��������
		AdcRate : double;	  			  						// �������� ������� ��� � ���
		InterKadrDelay : double;		  					// ����������� �������� � ��
		KadrRate : double;									// ������� ����� ����� � ���
	end;
	pADC_PARS_E140 = ^ADC_PARS_E140;

// ��������� ������ E14-440
ILE140 = class(Lusbbase)
  public
		// ������� ��� ������ � ���
		Function GET_ADC_PARS(ap : pADC_PARS_E140) : BOOL; virtual; stdcall; abstract;
		Function SET_ADC_PARS(ap : pADC_PARS_E140) : BOOL; virtual; stdcall; abstract;
		Function START_ADC : BOOL; virtual; stdcall; abstract;
		Function STOP_ADC : BOOL; virtual; stdcall; abstract;
		Function ADC_KADR(Data : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function ADC_SAMPLE(AdcData : pSHORT; AdcChannel : WORD) : BOOL; virtual; stdcall; abstract;
		Function ReadData(ReadRequest : pIO_REQUEST_LUSBAPI) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���
		Function DAC_SAMPLE(DacData : pSHORT; DacChannel : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ��������� �������
		Function ENABLE_TTL_OUT(EnableTtlOut : BOOL) : BOOL; virtual; stdcall; abstract;
		Function TTL_IN(TtlIn : pWORD) : BOOL; virtual; stdcall; abstract;
		Function TTL_OUT(TtlOut : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���������������� ����������� ����
		Function ENABLE_FLASH_WRITE(IsFlashWriteEnabled : BOOL) : BOOL; virtual; stdcall; abstract;
		Function READ_FLASH_WORD(FlashAddress : WORD; FlashWord : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function WRITE_FLASH_WORD(FlashAddress : WORD; FlashWord : SHORT) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ �� ��������� ����������� ����
		Function GET_MODULE_DESCRIPTION(ModuleDescription : pMODULE_DESCRIPTION_E140) : BOOL; virtual; stdcall; abstract;
		Function SAVE_MODULE_DESCRIPTION(ModuleDescription : pMODULE_DESCRIPTION_E140) : BOOL; virtual; stdcall; abstract;

	end;
	pILE140 = ^ILE140;
