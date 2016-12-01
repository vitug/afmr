// Модуль для передачи общих типов и функций
unit CommonTypes;

interface
uses
  Windows, SysUtils, StdCtrls, Graphics;
const
  // Значения констант взято из модуля E2010
  // индексы доступных диапазонов входного напряжения модуля E20-10
	RANGE_3000mv				=	($00);
	RANGE_1000mv 				=	($01);
	RANGE_300mv 				=	($02);

	// индексы возможных типов подключения входного тракта модуля E20-10
	INPUT_GROUND				=	($00);
	INPUT_SIGNAL  			=	($01);

  // Индексы массива параметров цепи
  prmV0 = 0;
  prmL  = 1;
  prmR  = 2;
  prmT  = 3;
  prmC  = 4;

  // Чило точек усреднения для определения смещения нуля АЦП
  PointForZero = 100;

  //Число строк с комментариями в файлах данных с АПЦ использующихся для отладки
  FileDebugComment = 3;
  //Число праметров в строке файла данных с АЦП использующего для отладки (Например '123' '456' '789')
  FileDebugParam = 3;

  //Флаги показывающие как обнвить данные (форма-программа или программа-форма)
  FormToSpectrometer = 0;
  SpectrometerToForm = 1;

type
  // Буффер (массив) для сбора данных
  TShortrArray = array of SHORT;

  // данные канала 
  TChannelData = Packed Record
    quantization_step: SHORT;
    voltage: double;
    time: double;
  end;

  TADC_DATA = array of TChannelData; // Данные с АЦП для обработки по конктретному каналу

  TAdcDataOfChannel = array of array of TChannelData;  // Данные всех каналов

  TLogicalCnannel = record
    Number      :WORD;   // номер активного физического канала
    Repeating   :WORD;   // Число повторений опроса
    InputRange  :WORD;   // входной диапазон, В
    InputSwitch :WORD;   // источник входа
  end;

  TControlTable = array of TLogicalCnannel; // максимальная длина массива 256 элементов.

  TPulseEdgeCoefSet = record //набор коэффициентов для переднего и задрего фронта
    k1,
    k2,
    k3: double;
  end;

  PTParameters = ^TParameters;
  TParameters = array [0..4] of Double; // набор параметров цепи

  TFrontBack = (fbFront, fbBack, fbFull); //передняя или задняя часть импульса или целиком
  TUnitSignal = (unVolt, unDiskret);//единица измерения сигнала АЦП вольты или дискреты

  TKindOfUnit = record //Единицы измерения с АЦП (вольты дискреты)
    Quant: SHORT;
    Voltage: double;
  end;

  TSpectrXY = record    // элемент массива спектр: X- расчетное поле Y- сигна поглощения
    x: double;
    y: TKindOfUnit;
  end;

  TSpectrData = array of TSpectrXY; // массив данных спектра

  TFileADC_Data = array of String[30]; //Строка из файла данных АЦП (для отладки)
  //0 - вермя
  //1 - значение в дискретах
  //2 - значение в вольтах

  // Запись параметров спектра
  TSpectrDescription = record
    Crystal,                        // Образец
    Generator,                      // Модель генератора
    Section,                        // Секция
    Thermopair,                     // Термопара
    Orientation,                    // Ориентация образца
    Comment: String;                // Комментрарий
    Temperature: double;            // Температура
    Frequency: double;              // Частота СВЧ генератора
    Angle: double;                  // Угол поворота
    ChargeVoltage: double;          // Напряжение заряда бат.
    FrontBack: TFrontBack;          // Фронт импульса
    ErrorFit: double;               //Ошибка среднеквадратичная
    ThermopairVoltage: double;      // Напряжение на термопаре
    AmplifierScale: double;         // Шкала дополнительного усилителя
    ADCFrequency: integer;          // Частота АЦП
    ADCFieldDivSignal: string;      // Делитель частоты АЦП 1(поле)/10(сигнал)
  end;

  //Запись для хранения последних данных установленных в свойствах эксперимента
  //Используется для сохранения и чтения из файла
  TLastChangesExperiment =  record
    Crystal,                        // Образец
    Generator,                      // Модель генератора
    Section,                        // Секция
    Thermopair,                     // Термопара
    Comment,                        // Комментрарий
    Orientation: String;            // Ориентация образца
  end;

  //Пытается корректо перевести строку в число с плавающей запятой
  function ConvertStringInFloat(Value: String): double;

  //Проверяет поле ввода TEdit на корректность ввода числа 
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
  //Выполним необходимые изменения форматирования
  GetLocaleFormatSettings(SysLocale.DefaultLCID, FormatSettings);
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ShortDateFormat := 'yyyy_MM_dd';
  FormatSettings.LongTimeFormat := 'HH_mm_ss';
end.
