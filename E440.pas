// *****************************************************************************
// ******************  � � � � � �    E 1 4 - 4 4 0  ***************************
// *****************************************************************************

// ���������
const
	// ����� ������ �������� ������ LBIOS ( ������������� � ������ �������� DSP ������)
	VarsBaseAddress_E440 					= $30;

	// ������ ���������� �������� LBIOS ��� ������ E14-440 (������������ � ������ �������� DSP ������)
	L_PROGRAM_BASE_ADDRESS_E440		  	= 	(VarsBaseAddress_E440 + $0);
	L_READY_E440   							= 	(VarsBaseAddress_E440 + $1);
	L_TMODE1_E440   							= 	(VarsBaseAddress_E440 + $2);
	L_TMODE2_E440	   						= 	(VarsBaseAddress_E440 + $3);
	L_TEST_LOAD_E440	 						= 	(VarsBaseAddress_E440 + $4);
	L_COMMAND_E440		 						= 	(VarsBaseAddress_E440 + $5);

	L_DAC_SCLK_DIV_E440 						= 	(VarsBaseAddress_E440 + $7);
	L_DAC_RATE_E440	 						= 	(VarsBaseAddress_E440 + $8);
	L_ADC_RATE_E440	 						= 	(VarsBaseAddress_E440 + $9);
	L_ADC_ENABLED_E440 						= 	(VarsBaseAddress_E440 + $A);
	L_ADC_FIFO_BASE_ADDRESS_E440			= 	(VarsBaseAddress_E440 + $B);
	L_CUR_ADC_FIFO_LENGTH_E440				= 	(VarsBaseAddress_E440 + $C);
	L_ADC_FIFO_LENGTH_E440					= 	(VarsBaseAddress_E440 + $E);
	L_CORRECTION_ENABLED_E440				= 	(VarsBaseAddress_E440 + $F);

	L_ADC_SAMPLE_E440							= 	(VarsBaseAddress_E440 + $11);
	L_ADC_CHANNEL_E440	 					= 	(VarsBaseAddress_E440 + $12);
	L_INPUT_MODE_E440							= 	(VarsBaseAddress_E440 + $13);

	L_SYNCHRO_AD_CHANNEL_E440				= 	(VarsBaseAddress_E440 + $16);
	L_SYNCHRO_AD_POROG_E440					= 	(VarsBaseAddress_E440 + $17);
	L_SYNCHRO_AD_MODE_E440 					= 	(VarsBaseAddress_E440 + $18);
	L_SYNCHRO_AD_TYPE_E440 					= 	(VarsBaseAddress_E440 + $19);

	L_CONTROL_TABLE_LENGHT_E440			= 	(VarsBaseAddress_E440 + $1B);
	L_FIRST_SAMPLE_DELAY_E440				= 	(VarsBaseAddress_E440 + $1C);
	L_INTER_KADR_DELAY_E440					= 	(VarsBaseAddress_E440 + $1D);

	L_DAC_SAMPLE_E440							= 	(VarsBaseAddress_E440 + $20);
	L_DAC_ENABLED_E440					 	= 	(VarsBaseAddress_E440 + $21);
	L_DAC_FIFO_BASE_ADDRESS_E440			= 	(VarsBaseAddress_E440 + $22);
	L_CUR_DAC_FIFO_LENGTH_E440				= 	(VarsBaseAddress_E440 + $24);
	L_DAC_FIFO_LENGTH_E440					= 	(VarsBaseAddress_E440 + $25);

	L_FLASH_ENABLED_E440 					= 	(VarsBaseAddress_E440 + $26);
	L_FLASH_ADDRESS_E440 					= 	(VarsBaseAddress_E440 + $27);
	L_FLASH_DATA_E440 						= 	(VarsBaseAddress_E440 + $28);

	L_ENABLE_TTL_OUT_E440					= 	(VarsBaseAddress_E440 + $29);
	L_TTL_OUT_E440								= 	(VarsBaseAddress_E440 + $2A);
	L_TTL_IN_E440								= 	(VarsBaseAddress_E440 + $2B);

	L_SCALE_E440								= 	(VarsBaseAddress_E440 + $30);
	L_ZERO_E440									= 	(VarsBaseAddress_E440 + $34);

	L_CONTROL_TABLE_E440						=	($80);

	L_DSP_INFO_STUCTURE_E440				=	($200);

	// ������� ��������� ��������� ������ ������ E14-440
	INIT_E440									=	($00);
	RESET_E440									=	($01);
	INVALID_RESET_TYPE_E440					=	($02);

	// ������� ��������� ���������� �������� ���������� ������ E14-440
	ADC_INPUT_RANGE_10000mV_E440			=	($00);
	ADC_INPUT_RANGE_2500mV_E440			=	($01);
	ADC_INPUT_RANGE_625mV_E440				=	($02);
	ADC_INPUT_RANGE_156mV_E440				=	($03);
	INVALID_ADC_INPUT_RANGE_E440			=	($04);

	// ������� ��������� ����� ������������� ������ E14-440
	NO_SYNC_E440								=	($00);
	TTL_START_SYNC_E440						=	($01);
	TTL_KADR_SYNC_E440						=	($02);
	ANALOG_SYNC_E440							=	($03);
	INVALID_SYNC_E440							=	($04);

	// ������� ��������� ����� ������� ���������� ���
	DAC_INACCESSIBLED_E440					=	($00);
	DAC_ACCESSIBLED_E440						=	($01);
	INVALID_DAC_OPTION_E440					=	($02);

	// ������� ��������� ����� DSP (������ ������ ADSP-2185)
	ADSP2184_E440								=	($00);
	ADSP2185_E440								=	($01);
	ADSP2186_E440								=	($02);
	INVALID_DSP_TYPE_E440					=	($03);

	// ������� ��������� �������� ������ ������ (������ ������ 24000 ���)
	F14745_E440									=	($00);
	F16667_E440									=	($01);
	F20000_E440									=	($02);
	F24000_E440									=	($03);
	INVALID_QUARTZ_FREQ_E440				=	($04);

	// ������� ��������� ������� ������ E14-440
	REVISION_A_E440	  						=	($00);
	REVISION_B_E440	  						=	($01);
	REVISION_C_E440	  						=	($02);
	REVISION_D_E440							=	($03);
	REVISION_E_E440							=	($04);
	INVALID_REVISION_E440					=	($05);

	// ��������� ��� ������ � �������
	MAX_CONTROL_TABLE_LENGTH_E440			=	(128);
	ADC_INPUT_RANGES_QUANTITY_E440		=	(INVALID_ADC_INPUT_RANGE_E440);
	ADC_CALIBR_COEFS_QUANTITY_E440		=	(ADC_INPUT_RANGES_QUANTITY_E440);
	MAX_ADC_FIFO_SIZE_E440					=	($3000);			// 12288
	DAC_CHANNELS_QUANTITY_E440				=	($02);
	DAC_CALIBR_COEFS_QUANTITY_E440		=	(DAC_CHANNELS_QUANTITY_E440);
	MAX_DAC_FIFO_SIZE_E440					=	($0FC0);			// 4032
	TTL_LINES_QUANTITY_E440					=	($10);							// ���-�� �������� �����
	REVISIONS_QUANTITY_E440 				=	(INVALID_REVISION_E440);	// ���-�� ������� (�����������) ������

	// ��������� �������� ���������� ��� � �
	ADC_INPUT_RANGES_E440 : array [0..(ADC_INPUT_RANGES_QUANTITY_E440-1)]  of double =	( 10.0, 10.0/4.0, 10.0/16.0, 10.0/64.0 );
	// ��������� ��������� ���������� ��� � �
	DAC_OUTPUT_RANGE_E440					=	5.0;
	// ��������� ������� ������
	REVISIONS_E440 : array [0..(REVISIONS_QUANTITY_E440-1)] of char = ( 'A', 'B', 'C', 'D', 'E'  );

   
// ����
type
	// ��������� � ����������� �� ������ E14-440
	MODULE_DESCRIPTION_E440 = packed record
		Module 		: MODULE_INFO_LUSBAPI;		  	// ����� ���������� � ������
		DevInterface	: INTERFACE_INFO_LUSBAPI;	// ���������� �� ������������ ����������� ����������
		Mcu			: MCU_INFO_LUSBAPI;				// ���������� � ����������������
		Dsp			: DSP_INFO_LUSBAPI;				// ���������� � DSP
		Adc			: ADC_INFO_LUSBAPI;				// ���������� � ���
		Dac			: DAC_INFO_LUSBAPI;				// ���������� � ���
		DigitalIo	: DIGITAL_IO_INFO_LUSBAPI;		// ���������� � �������� �����-������
	end;
	pMODULE_DESCRIPTION_E440 = ^MODULE_DESCRIPTION_E440;

	// ��������� ���������� ������ ��� ��� ������ E14-440
	ADC_PARS_E440 = packed record
		IsAdcEnabled : BOOL;			  						// ������ ����������/���������� ����� ������ (������ ��� ������)
		IsCorrectionEnabled : BOOL;						// ���������� ���������� �������������� ������ �� ������ �������� DSP
		InputMode : WORD;										// ����� ����� ����� � ���
		SynchroAdType : WORD;								// ��� ���������� �������������
		SynchroAdMode : WORD; 								// ����� ���������� ������������
		SynchroAdChannel : WORD;  							// ����� ��� ��� ���������� �������������
		SynchroAdPorog : SHORT;								// ����� ������������ ��� ��� ���������� �������������
		ChannelsQuantity : WORD;							// ����� �������� ���������� �������
		ControlTable : array [0..(MAX_CONTROL_TABLE_LENGTH_E440-1)] of WORD;	// ����������� ������� � ��������� ����������� ��������
		AdcRate : double;	  			  						// �������� ������� ��� � ���
		InterKadrDelay : double;		  					// ����������� �������� � ��
		KadrRate : double;									// ������� ����� � ���
		AdcFifoBaseAddress : WORD;							// ������� ����� FIFO ������ �����
		AdcFifoLength : WORD;	  							// ����� FIFO ������ �����
		AdcOffsetCoefs : array [0..3] of double; 		// ���������������� ����. �������� ���� ��� ���
		AdcScaleCoefs : array [0..3] of double; 		// ���������������� ����. �������� ��� ���
	end;
	pADC_PARS_E440 = ^ADC_PARS_E440;

	// ��������� ���������� ������ ��� ������ E14-440
	DAC_PARS_E440 = packed record
		DacEnabled : BOOL;									// ����������/���������� ������ ������
		DacRate : double;	  		  							// ������� ������ ������ � ���
		DacFifoBaseAddress : WORD;  						// ������� ����� FIFO ������ ������
		DacFifoLength : WORD;								// ����� FIFO ������ ������
	end;
	pDAC_PARS_E440 = ^DAC_PARS_E440;

// ��������� ������ E14-440
ILE440 = class(Lusbbase)
  public
		// ������� ��� ������ � DSP ������
		Function RESET_MODULE(ResetFlag : BYTE = INIT_E440) : BOOL; virtual; stdcall; abstract;
		Function LOAD_MODULE(FileName : pCHAR = nil) : BOOL; virtual; stdcall; abstract;
		Function TEST_MODULE : BOOL; virtual; stdcall; abstract;
		Function SEND_COMMAND(Command : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���
		Function GET_ADC_PARS(ap : pADC_PARS_E440) : BOOL; virtual; stdcall; abstract;
		Function SET_ADC_PARS(ap : pADC_PARS_E440) : BOOL; virtual; stdcall; abstract;
		Function START_ADC : BOOL; virtual; stdcall; abstract;
		Function STOP_ADC : BOOL; virtual; stdcall; abstract;
		Function ADC_KADR(Data : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function ADC_SAMPLE(AdcData : pSHORT; AdcChannel : WORD) : BOOL; virtual; stdcall; abstract;
		Function ReadData(ReadRequest : pIO_REQUEST_LUSBAPI) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ���
		Function GET_DAC_PARS(dm : pDAC_PARS_E440) : BOOL; virtual; stdcall; abstract;
		Function SET_DAC_PARS(dm : pDAC_PARS_E440) : BOOL; virtual; stdcall; abstract;
		Function START_DAC : BOOL; virtual; stdcall; abstract;
		Function STOP_DAC : BOOL; virtual; stdcall; abstract;
		Function WriteData(WriteRequest : pIO_REQUEST_LUSBAPI) : BOOL; virtual; stdcall; abstract;
		Function DAC_SAMPLE(DacData : pSHORT; DacChannel : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ��������� �������
		Function ENABLE_TTL_OUT(EnableTtlOut : BOOL) : BOOL; virtual; stdcall; abstract;
		Function TTL_IN(TtlIn : pWORD) : BOOL; virtual; stdcall; abstract;
		Function TTL_OUT(TtlOut : WORD) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ ����
		Function ENABLE_FLASH_WRITE(EnableFlashWrite : BOOL) : BOOL; virtual; stdcall; abstract;
		Function READ_FLASH_WORD(FlashAddress : WORD; FlashWord : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function WRITE_FLASH_WORD(FlashAddress : WORD; FlashWord : SHORT) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ �� ��������� ����������� �� ����
		Function GET_MODULE_DESCRIPTION(ModuleDescription : pMODULE_DESCRIPTION_E440) : BOOL; virtual; stdcall; abstract;
		Function SAVE_MODULE_DESCRIPTION(ModuleDescription : pMODULE_DESCRIPTION_E440) : BOOL; virtual; stdcall; abstract;

		// ������� ��� ������ � ������� DSP
		Function PUT_LBIOS_WORD(Address : WORD; Data : SHORT) : BOOL; virtual; stdcall; abstract;
		Function GET_LBIOS_WORD(Address : WORD; Data : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function PUT_DM_WORD(Address : WORD; Data : SHORT) : BOOL; virtual; stdcall; abstract;
		Function GET_DM_WORD(Address : WORD; Data : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function PUT_PM_WORD(Address : WORD; Data : DWORD) : BOOL; virtual; stdcall; abstract;
		Function GET_PM_WORD(Address : WORD; Data : pDWORD) : BOOL; virtual; stdcall; abstract;
		Function PUT_DM_ARRAY(BaseAddress, NPoints : WORD; Data : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function GET_DM_ARRAY(BaseAddress, NPoints : WORD; Data : pSHORT) : BOOL; virtual; stdcall; abstract;
		Function PUT_PM_ARRAY(BaseAddress, NPoints : WORD; Data : pDWORD) : BOOL; virtual; stdcall; abstract;
		Function GET_PM_ARRAY(BaseAddress, NPoints : WORD; Data : pDWORD) : BOOL; virtual; stdcall; abstract;
	end;
	pILE440 = ^ILE440;
