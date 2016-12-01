unit e24api;

interface
uses Windows;
////////////////////////////////////////////////////////////////////////////////
// Команды для выбора подключения каналов
const
   MDIN0=0;     // вход 0 канала
   MDIN1=1;     // вход 1 канала
   EXT_TEST=2;     // внешшнее тестовое подключение
   INT_TEST=3;     // внутренее тестовое подключение

////////////////////////////////////////////////////////////////////////////////
// Выбор каналов; можно комбинировать по ИЛИ
   CODECALL=$F;   // для всех каналов
   CODEC0=1;     // для 0
   CODEC1=2;     // для 1
   CODEC2=4;     // для 2
   CODEC3=8;     // для 3

////////////////////////////////////////////////////////////////////////////////
// Константы для установки коэффициентов усиления
   KU1=0;
   KU2=1;
   KU4=2;
   KU8=3;
   KU16=4;
   KU32=5;
   KU64=6;
   KU128=7;

////////////////////////////////////////////////////////////////////////////////
// Режимы калибровки
   NORMAL=0;
   AUTOCAL=1;
   EXTCAL0=2;
   EXTCALM=3;
   FULLCAL=4;
   FONCAL=5;
   INTCAL0=6;
   INTCALM=7;

////////////////////////////////////////////////////////////////////////////////
// Константы скорости для последовательного порта
   B2400=0;
   B4800=1;
   B9600=2;
   B19200=3;
   B38400=4;
   B57600=5;

function SendCommand(hCom:DWORD; cmd:BYTE; par:WORD; length:DWORD):DWORD;stdcall;

function ConfigE24Chan(hCom:DWORD; mode:WORD; chan:BYTE):DWORD;stdcall;

function SetGain(hCom:DWORD; gain:WORD; mode:WORD; chan:BYTE):DWORD;stdcall;

function RefreshParam(hCom:DWORD; chan:BYTE):DWORD;stdcall;

function SetActiveChan(hCom:DWORD; chan:BYTE):DWORD;stdcall;

function ResetCounter(hCom:DWORD):DWORD;stdcall;

function ConfigE24COM(hCom:DWORD; baud:BYTE):DWORD;stdcall;

function SetE24Rate(hCom:DWORD; code:WORD; chan:BYTE; freq:PDouble):DWORD;stdcall;

function SetEEPROMAddress(hCom:DWORD; Addr:WORD):DWORD;stdcall;

function GetEEPROMByte(hCom:DWORD; btret:PBYTE):DWORD;stdcall;

function SetEEPROMByte(hCom:DWORD; bt:BYTE):DWORD;stdcall;

function Set5byteMode(hCom:DWORD):DWORD;stdcall;

function Set4byteMode(hCom:DWORD):DWORD;stdcall;

function GetParameters(hCom:DWORD; param:PBYTE):DWORD;stdcall;

function ConvertE24Block(hCom:DWORD; Buf:PBYTE; length:BYTE; ad_data:PINT; p:PBYTE; chan:PBYTE; counter:PBYTE; err:PBYTE):DWORD;stdcall;

function InitE24(Com:LPSTR; Baud:BYTE):DWORD;stdcall;

function StopE24(hCom:DWORD):DWORD;stdcall;

function ReadComData(hCom:DWORD; data:PBYTE; count:DWORD):DWORD;stdcall;

procedure FreeComPort(hCom:DWORD);stdcall;

implementation

function SendCommand(hCom:DWORD; cmd:BYTE; par:WORD; length:DWORD):DWORD;external 'e24api.dll';

function ConfigE24Chan(hCom:DWORD; mode:WORD; chan:BYTE):DWORD;external 'e24api.dll';

function SetGain(hCom:DWORD; gain:WORD; mode:WORD; chan:BYTE):DWORD;external 'e24api.dll';

function RefreshParam(hCom:DWORD; chan:BYTE):DWORD;external 'e24api.dll';

function SetActiveChan(hCom:DWORD; chan:BYTE):DWORD;external 'e24api.dll';

function ResetCounter(hCom:DWORD):DWORD;external 'e24api.dll';

function ConfigE24COM(hCom:DWORD; baud:BYTE):DWORD;external 'e24api.dll';

function SetE24Rate(hCom:DWORD; code:WORD; chan:BYTE; freq:PDouble):DWORD;external 'e24api.dll';

function SetEEPROMAddress(hCom:DWORD; Addr:WORD):DWORD;external 'e24api.dll';

function GetEEPROMByte(hCom:DWORD; btret:PBYTE):DWORD;external 'e24api.dll';

function SetEEPROMByte(hCom:DWORD; bt:BYTE):DWORD;external 'e24api.dll';

function Set5byteMode(hCom:DWORD):DWORD;external 'e24api.dll';

function Set4byteMode(hCom:DWORD):DWORD;external 'e24api.dll';

function GetParameters(hCom:DWORD; param:PBYTE):DWORD;external 'e24api.dll';

function ConvertE24Block(hCom:DWORD; Buf:PBYTE; length:BYTE; ad_data:PINT; p:PBYTE; chan:PBYTE; counter:PBYTE; err:PBYTE):DWORD;external 'e24api.dll';

function InitE24(Com:LPSTR; Baud:BYTE):DWORD;external 'e24api.dll';

function StopE24(hCom:DWORD):DWORD;external 'e24api.dll';

function ReadComData(hCom:DWORD; data:PBYTE; count:DWORD):DWORD;external 'e24api.dll';

procedure FreeComPort(hCom:DWORD);external 'e24api.dll';


end.