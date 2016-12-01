unit Lcard;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Math,
  Lusbapi, //Модуль для работы с платой
  CommonTypes;

type
  TPlata = class
  private
    // интерфейс модуля E20-10
    pModule: ILE2010;
    // версия библиотеки Rtusbapi.dll
	  DllVersion: DWORD;
	  // идентификатор устройства
	  ModuleHandle: THandle;
	  // название модуля
	  ModuleName: String;
	  // скорость работы шины USB
	  UsbSpeed: BYTE;
    // Скорость шины в текстовом виде для информирования
    StrUsbSpeed: String;
    // структура с полной информацией о модуле
	  ModuleDescription: MODULE_DESCRIPTION_E2010;
	  // структура параметров работы АЦП
	  ap: ADC_PARS_E2010;
	  // буфер пользовательского ППЗУ
    UserFlash: USER_FLASH_E2010;
    // структура с параметрами запроса на ввод/вывод данных
    IoReq: IO_REQUEST_LUSBAPI;
    //готовые данные с АЦП
    AdcData: TAdcDataofChannel;
    // кол-во отсчетов в запросе ReadData
  	DataStep: DWORD;
    // длительность измеряемого сигнала в мс
    Duration: WORD;
    // частота ввода данных в кГц
  	AdcRate: double;
    // частота кадров
    KadrRate: double;
    // Межкадровая задержка
    KadrDelay: double;
    //Контрольная таблица опроса каналов
    ControlTable: TControlTable;

    // указатель на буфер для данных
	  AdcBuffer: TShortrArray;

    // статус готовности платы
   // Status: boolean;

    procedure AbortProgram(ErrorString: string; AbortionFlag: boolean = false);  //Аварийная остановка

    procedure ParseData();                                      // Разбор данных
  public
    constructor PlataCreate();                                  // Конструктор
    destructor  Destroy;
    procedure AddChannel(Channel: TLogicalCnannel);             // Добавляет логический канал в контрольную таблицу
    procedure ClearControlTable();                              // Очищает контрольную таблицу
    procedure Fill_ADC_PARS_2010;                               // Подготавливает параметры работы АЦП
    function  Start_ADC(): boolean;                             // Запуск АЦП
    procedure Stop_ADC();                                       // Стоп АЦП
    function LengthControlTable: WORD;                          // Возвращает длину контрольной таблицы
    function GetScaleOfChannel(Ch: WORD): double;               // Возвращает шкалу по каналу в вольтах
    function IsReady: boolean;                                  // Готовность платы
    procedure SetStateDigitalOutputRegisters(OnOff: Boolean);            // Включение/выключение цифровых регистров
    procedure Out(Value: Integer);                              //записать в выходной регистр значение
    function Input():Integer;                                      //Прочитать из выходного регистра значение
    //    property IsReady: boolean read Status;
    property RateAdc: double read AdcRate write AdcRate;        // Чатота работы АЦП
    property RateKadr: double read KadrRate;                    // Частота кадров
    property DuratoinSignal: WORD read Duration write Duration; // Длительность измеряемого сигнала
    property AdcDataArray: TAdcDataOfChannel read AdcData;      // Массив данных по всем каналам АЦП
    property UsbSpeedTxt: String read StrUsbSpeed;
  end;

implementation

{ TPlata }

procedure TPlata.AbortProgram(ErrorString: string; AbortionFlag: boolean);
begin
  // статус платы "Не готова"
  //Status := false;

	// освободим интерфейс модуля
	if pModule <> nil then
	begin
	  // освободим интерфейс модуля
		if pModule.ReleaseLInstance() then
      // обнулим указатель на интерфейс модуля
			pModule := nil;
  end;

	// освободим память из-под буферов данных
	AdcBuffer := nil;
  AdcData := nil;
  ControlTable := nil;

	// если нужно - выводим сообщение с ошибкой
	if ErrorString <> '' then
    MessageBox(HWND(nil), pCHAR(ErrorString), 'ОШИБКА!', MB_OK + MB_ICONERROR);
	// если нужно - аварийно завершаем программу
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
	// установим желаемые параметры ввода данных с модуля E20-10
	if ModuleDescription.Module.Revision = BYTE(REVISIONS_E2010[REVISION_A_E2010]) then
		ap.IsAdcCorrectionEnabled := FALSE				// запретим автоматическую корректировку данных на уровне модуля (для Rev.A)
	else
  begin
		ap.IsAdcCorrectionEnabled := TRUE; 				// разрешим автоматическую корректировку данных на уровне модуля (для Rev.B и выше)
		ap.SynchroPars.StartDelay := 0;
		ap.SynchroPars.StopAfterNKadrs := 0;
		ap.SynchroPars.SynchroAdMode := NO_ANALOG_SYNCHRO_E2010;
//		ap.SynchroPars.SynchroAdMode := ANALOG_SYNCHRO_ON_HIGH_LEVEL_E2010;
		ap.SynchroPars.SynchroAdChannel := $0;
		ap.SynchroPars.SynchroAdPorog := 0;
		ap.SynchroPars.IsBlockDataMarkerEnabled := $0;
	end;
	ap.SynchroPars.StartSource := INT_ADC_START_E2010;			// внутренний старт сбора с АЦП
	ap.SynchroPars.SynhroSource := INT_ADC_CLOCK_E2010;			// внутренние тактовые импульсы АЦП
//	ap.OverloadMode := MARKER_OVERLOAD_E2010;			// фиксация факта перегрузки входных каналов при помощи маркеров в отсчёте АЦП (только для Rev.A)
 	ap.OverloadMode := CLIPPING_OVERLOAD_E2010;		  // обычная фиксация факта перегрузки входных каналов путём ограничения отсчёта АЦП (только для Rev.A)

  // Конфигурация каналов поумолчанию
  for i:=0 to (ADC_CHANNELS_QUANTITY_E2010-1) do
  begin
	  ap.InputRange[i] := ADC_INPUT_RANGE_3000mV_E2010; 	// входной диапазон 3В
		ap.InputSwitch[i] := ADC_INPUT_ZERO_E2010;			    // источник входа - аналоговая земля модуля.
  end;

  // кол-во активных каналов (размер кадра)
  k := 0;
  for i := 0 to Length(ControlTable) - 1 do
  begin
    k := k + ControlTable[i].Repeating;
  end;
  // Если кол-во логических каналов больше максимаольного, то ограничим до максимума
  if k >= MAX_CONTROL_TABLE_LENGTH_E2010 then
  begin
    k := 256;
    MessageBox(HWND(Nil), 'Превышено максимальное клоичество логических каналов в управляющей таблице! установлено 256',
      'Внимание!', MB_OK + MB_ICONWARNING);
  end;

  ap.ChannelsQuantity := k; // передадим в стр-ру кол-во активных каналов (размер кадра)

  // Заполним управляющую таблицу АЦП из подготовленной контрольной таблицы
  k := 0;
  for i := 0 to Length(ControlTable) - 1 do
    for j := 0 to ControlTable[i].Repeating - 1 do
    begin
      ap.ControlTable[k] := ControlTable[i].Number - 1; //Номер канала
      // конфигурим входной канал
      ap.InputRange[ControlTable[i].Number - 1] := ControlTable[i].InputRange; 	 // входной диапазон
      ap.InputSwitch[ControlTable[i].Number - 1] := ControlTable[i].InputSwitch; // источник входа 
      k := k + 1;
	  end;

	ap.AdcRate := AdcRate;		 	  // частота АЦП данных в кГц
  ap.InterKadrDelay := 0.0;	   	// межкадровая задержка в мс; (минимально возможная 1/AdcRate)

	// передаём в структуру параметров работы АЦП корректировочные коэффициенты АЦП
 	for i := 0 to (ADC_INPUT_RANGES_QUANTITY_E2010 - 1) do
		for j := 0 to (ADC_CHANNELS_QUANTITY_E2010 - 1) do
		begin
			// корректировка смещения
 			ap.AdcOffsetCoefs[i][j] := ModuleDescription.Adc.OffsetCalibration[j + i * ADC_CHANNELS_QUANTITY_E2010];
			// корректировка масштаба
 			ap.AdcScaleCoefs[i][j] := ModuleDescription.Adc.ScaleCalibration[j + i * ADC_CHANNELS_QUANTITY_E2010];
		end;

	// передадим в модуль требуемые параметры по вводу данных
	if not pModule.SET_ADC_PARS(@ap) then
  begin
    AbortProgram('Не могу установить параметры ввода данных!');
    exit;
  end;

   // получим текущие параметры работы ввода данных
 	if not pModule.GET_ADC_PARS(@ap) then
  begin
    AbortProgram('Не могу получить текущие параметры ввода данных!');
    exit;
  end;     
  // обновим параметры класса реальными значениями
  AdcRate := ap.AdcRate;
  KadrRate := ap.KadrRate;
  KadrDelay := ap.InterKadrDelay;

  //Остановим плату перед стартом
  if not pModule.STOP_ADC then
  begin
    AbortProgram('Не могу выпонить "СТОП" перед запуском!');
    exit;
  end;

  // Расчиттаем необходимое кол-во отсчетов АЦП для записи сигнала длительностью t мс
  DataStep := Round((Duration / (1 / KadrRate))) * ap.ChannelsQuantity;
  Exponent := Round(Log2(Duration / (1 / KadrRate)* ap.ChannelsQuantity));
  if not (Power(2, Exponent) >= DataStep) then
    DataStep := round(Power(2, Exponent) * 2)
  else
    DataStep := round((Power(2, Exponent)));

  if not (DataStep <= 1024*1024) then
  begin
    s := 'Для синхронного запуска слишком много отсчетов АЦП' + #13 +
      'система будет долго не отвечать на сообщения пользователя' + #13 +
      'в дальнейшем попробуйте снизить частоту АЦП или уменьшить длительность сигнала.';
    MessageBox(HWND(nil), Pchar(s) , 'Предупреждение', MB_OK + MB_ICONWARNING);
  end;

  // попробуем выделить нужное кол-во памяти под буфер данных
  AdcBuffer := nil;
  SetLength(AdcBuffer, DataStep);

  // формируем структуру IoReq
  IoReq.Buffer := Pointer(AdcBuffer);			// буфер данных
	IoReq.NumberOfWordsToPass := DataStep;	// кол-во собираемых данных
 	IoReq.NumberOfWordsPassed := 0;
	IoReq.Overlapped := nil;					      // синхронный вариант запроса
	IoReq.TimeOut := Round(int(DataStep/ap.KadrRate)) + 1000;	// таймаут синхронного сбора данных

end;


function TPlata.GetScaleOfChannel(Ch: WORD): double;
var
  Scale: WORD;

begin
  Result := 0;
  if not IsReady then
  begin
    AbortProgram('Не могу получить масштаб');
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

  i := 0; // начало отсчетов
  CurTime := 0; //Текущее время
  QuantityKadr := trunc(DataStep / ap.ChannelsQuantity);     //кол-во кадров
  for k := 0 to QuantityKadr - 1 do
  begin
    for j := 0 to ap.ChannelsQuantity - 1 do   //кол-во аквтивных каналов
    begin
      SetLength(AdcData[ap.ControlTable[j]], Length(AdcData[ap.ControlTable[j]]) + 1);
      AdcData[ap.ControlTable[j]][Length(AdcData[ap.ControlTable[j]])-1].quantization_step := TShortrArray(IoReq.Buffer)[i]; // Дискреты
      case ap.InputRange[ap.ControlTable[j]] of
        0: Scale := 3;
        1: Scale := 1;
        2: Scale := 0.3;
      end;
      AdcData[ap.ControlTable[j]][Length(AdcData[ap.ControlTable[j]])-1].voltage := TShortrArray(IoReq.Buffer)[i]/8192 * Scale;    // Вольты
      AdcData[ap.ControlTable[j]][Length(AdcData[ap.ControlTable[j]])-1].time := CurTime;     // Время
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

  //сбросим статус готовности платы
  //Status := true;

  DataStep := 1024;
  AdcRate := 1000; // 1 МГц
  Duration := 13;  // 13 мс
  ControlTable := nil;

  // проверим версию используемой DLL библиотеки
	DllVersion := GetDllVersion;
	if DllVersion <> CURRENT_VERSION_LUSBAPI then
  begin
	  Str := 'Неверная версия DLL библиотеки Lusbapi.dll! ' + #10#13 +
		  ' Текущая: ' + IntToStr(DllVersion shr 16) +  '.' +
      IntToStr(DllVersion and $FFFF) + '.' +  ' Требуется: ' +
      IntToStr(CURRENT_VERSION_LUSBAPI shr 16) + '.' +
      IntToStr(CURRENT_VERSION_LUSBAPI and $FFFF) + '.';
			AbortProgram(Str);
    exit;
  end;

	// попробуем получить указатель на интерфейс для модуля E20-10
	pModule := CreateLInstance(pCHAR('e2010'));
	if pModule = nil then
  begin
    AbortProgram('Не могу найти интерфейс модуля E20-10!');
    exit;
  end;

  // попробуем обнаружить модуль E20-10 в первых MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI виртуальных слотах
	for i := 0 to (MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI-1) do
    if pModule.OpenLDevice(i) then
      break;

	// что-нибудь обнаружили?
	if i = MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI then
  begin
    AbortProgram('Не удалось обнаружить модуль E20-10 в первых 127 виртуальных слотах!');
    exit;
  end;

	// получим идентификатор устройства
	ModuleHandle := pModule.GetModuleHandle();

	// прочитаем название модуля в текущем виртуальном слоте
	ModuleName := '123456';
	if not pModule.GetModuleName(pCHAR(ModuleName)) then
  begin
    AbortProgram('Не могу прочитать название модуля!');
    exit;
  end;

	// проверим, что это модуль E20-10
	if Boolean(AnsiCompareStr(ModuleName, 'E20-10')) then
  begin
    AbortProgram('Обнаруженный модуль не является E20-10!');
    exit;
  end;

	// попробуем получить скорость работы шины USB
  if not pModule.GetUsbSpeed(@UsbSpeed) then
  begin
    AbortProgram(' Не могу определить скорость работы шины USB');
    exit;
  end;

	// теперь проверим скорость работы шины USB
	if UsbSpeed = USB11_LUSBAPI then
    StrUsbSpeed := 'USB Full-Speed Mode (12 Mbit/s)'
  else
    StrUsbSpeed := 'USB High-Speed Mode (480 Mbit/s)';


	// Образ для ПЛИС возьмём из соответствующего ресурса DLL библиотеки Lusbapi.dll
	if not pModule.LOAD_MODULE(nil) then
  begin
    AbortProgram('Не могу загрузить модуль E20-10!');
    exit;
  end;

	// проверим загрузку модуля
 	if not pModule.TEST_MODULE() then
  begin
    AbortProgram('Ошибка в загрузке модуля E20-10!');
    exit;
  end;

	// теперь получим номер версии загруженного драйвера DSP
	if not pModule.GET_MODULE_DESCRIPTION(@ModuleDescription) then
  begin
    AbortProgram('Не могу получить информацию о модуле!');
    exit;
  end;

	// попробуем прочитать содержимое пользовательского ППЗУ
	if not pModule.READ_FLASH_ARRAY(@UserFlash) then
  begin
    AbortProgram('Не могу прочитать пользовательское ППЗУ!');
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

  // запустим АЦП
	if not pModule.START_ADC() then
  begin
    AbortProgram('Не могу выпонить "СТАРТ"!');
    exit;
  end;

	// быстренько делаем запрос на сбор данных
	if not pModule.ReadData(@IoReq) then
  begin
    Stop_ADC;
    AbortProgram('Не могу выполнить запрос на чтение данных');
    exit;
  end;

  //Собрали данные, теперь СТОП
  Stop_ADC;

  // Сразу выполним разборку данных
  ParseData;

  Result := True;
end;

procedure TPlata.Stop_ADC;
begin
  if not pModule.STOP_ADC then
  begin
    AbortProgram('Не могу выпонить "СТОП"!');
    exit;
  end;

  // прервём возможно незавершённый асинхронный запрос на приём данных
	if not CancelIo(ModuleHandle) then
  begin
    AbortProgram('Ошибка остановки незавершенного запроса на прием данных');
    exit;
  end;
end;

end.
