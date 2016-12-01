{************************************************************}
{                                                            }
{                 Модуль ХХХ                                 }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 25 июня 2001                               }
{                                                            }
{************************************************************}
Unit tempr_s;

interface

uses
  e24api, basic,
  SysUtils,Windows,Math, Dialogs;

const

  //золото-хромель относительно термостата
  //UliquidHelium = 6162;
  //UliquidNitrogen = 5029

  //медь-золото
  UliquidHelium = 1571;
  UliquidNitrogen = 801.139;

  //золото-хромель относительно льда
  //UliquidNitrogen = 3962.5;
  //UliquidHelium = 5095;

  TliquidHelium = 4.2;
  TliquidNitrogen = 77.2;

type
    PTemperatureSensor = ^TemperatureSensor;
    TemperatureSensor = class
    private
      hCom:DWORD;
      FTemperature: real;  //температура
      FU: real;
      FUnorm: real;
      FControlPoint: Real; //контрольная тока:гелий или азот
      FThreshold: double;  //порог сенсора
      FZeroCorrection:double;//Корретировка нуля
    protected
      procedure Measure;
      Procedure Normalize;
    public
      constructor Init;
      Procedure Calibrate(TempCP: real);//калибровка
      function GetTemp: real; virtual;
      function isData: boolean;
      function isReady: boolean;
      function UnderThreshold: boolean;//возвращает да если ниже порога
      function InvalidHandle(): Boolean;
      destructor Done; virtual;
      property Threshold: Double read FThreshold write FThreshold;
      property U: real read FU write FU;
      property Unorm: real read FUnorm write FUnorm;
      property ControlPoint: real read FControlPoint write FControlPoint;
      property ZeroCorrection: double read FZeroCorrection write FZeroCorrection;
    end;

implementation

//==================================================

constructor TemperatureSensor.Init;
var
   dwError:DWORD;
   freq:double;
begin
   hCom:=InitE24('COM1',B19200);

   ConfigE24Chan(hCom,MDIN0,CODECALL);
   SetE24Rate(hCom,500,CODECALL,@freq);
   SetGain(hCom,KU128,AUTOCAL,CODECALL);
   RefreshParam(hCom,CODECALL);
   StopE24(hCom);
   SetActiveChan(hCom,CODECALL);

   FU := 0;
   FThreshold := 5;
   FTemperature := 0;
   FControlPoint := UliquidHelium;
   FUnorm := UliquidHelium;

   if hCom = INVALID_HANDLE_VALUE then
   begin
     //Raise Exception.Create('Сенсор температуры::Ошибка при открытии порта COM1!');
     ShowMessage('Сенсор температуры::Ошибка при открытии порта COM1! В качестве сигнала с термопары будет выдаваться нулевое напряжения!');
   end;
end;

//--------------------------------------------------

function TemperatureSensor.UnderThreshold: boolean;
begin
  Result := (FTemperature <= FThreshold);
end;

//--------------------------------------------------

procedure TemperatureSensor.Measure;
var
   dwError,ret,i:DWORD;
   data:array [1..5] of BYTE;
   ad_d : integer;
   pr,chn,tmr,err: BYTE;
   tmp:BYTE;
   freq:double;
   isData:boolean;
begin
  {Data := (FIR^.ReadData(TempSensorInput));
  Mantissa := (Data and $FFFF);
  if ((Data and $F0000) = $80000) then
    Sign := -1
  else
    Sign := 1;
    FU := Sign * BinDectoBin(not Mantissa) * 1E-6;}
  if InvalidHandle() then
  begin
    FU := 0;
    Exit;
  end;


    i:=0;
    isData:=false;
    PurgeComm(hCom,PURGE_TXCLEAR or PURGE_RXCLEAR);
   while(i<10) do
   begin
      sleep(10);

      ReadComData(hCom,@data,4);
      ConvertE24Block(hCom,@data,4,@ad_d,@pr,@chn,@tmr,@err);
      Inc(i);
      if chn=0 then
      begin
        isData:=true;
        if ad_d=-8089600 then
          FU:=0
        else
          FU:=ad_d*2.5/128/Power(2,23);
      end;
      data[1]:=0;
   end;
   if not isData then
    FU:=0;
end;

//--------------------------------------------------

function TemperatureSensor.GetTemp: real;
var
  x: real;
  PrevTemperature:Real;
begin
  Measure;
  x := (FU * 1e6-FZeroCorrection) / FUnorm * FControlPoint;

  PrevTemperature := FTemperature;

  //медь-золото
  if x >= 1028 then
    FTemperature := (141.89235 + 0.04447 * x - 2.96321E-4
      * x * x + 2.11799E-7 * x * x * x - 4.88366E-11 * x * x * x * x)
  else
    FTemperature := 273.63571 - 0.45946 * x + 4.69695e-4 * x * x -
      3.42087e-7 * x * x * x + 1.11405e-10 * x * x * x * x;
    Result := FTemperature;

  if (Abs(PrevTemperature - FTemperature) > 20) and (PrevTemperature > 0) and (PrevTemperature < 1000) then
    FTemperature := PrevTemperature;
  //золото-хромель
  //относительно термостата
  //FTemperature:=(309.80746 - 0.03163*X - 2.91483E-6*X*X);
  //относительно льда
  //FTemperature:=(273 - 0.03771*X - 2.95307E-6*X*X);
  Result:=FTemperature;

end;

//--------------------------------------------------

function TemperatureSensor.isData: boolean;
begin
    Result := True;
end;

//--------------------------------------------------

function TemperatureSensor.isReady: boolean;
begin
    Result := True;
end;

//--------------------------------------------------

procedure TemperatureSensor.Normalize;
begin
  Measure;
  if FU <> 0 then
    FUnorm := FU * 1e6-FZeroCorrection;
end;

//--------------------------------------------------

procedure TemperatureSensor.Calibrate(TempCP: real);
begin
  if Abs(TempCP - TliquidHelium)<0.1 then
    FControlPoint := UliquidHelium
  else
    if Abs(TempCP - TliquidNitrogen)<0.1 then
      FControlPoint := UliquidNitrogen;
  Normalize;
end;

//--------------------------------------------------

destructor TemperatureSensor.Done;
begin
  
end;

//==================================================

function TemperatureSensor.InvalidHandle: Boolean;
begin
  Result := hCom = INVALID_HANDLE_VALUE;
end;

end.{unit temp_s}
