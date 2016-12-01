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
Unit v_meter;

interface

uses
  Lcard, Basic, ADC_Base, CommonTypes,
  SysUtils;

type
  PTVoltmeter = ^TVoltmeter;
  TVoltmeter = class(TObject)
  private
   Device: TPlata;
   FU: real;
   ADC: TAdcLevelSignal;
  protected
    //
  public
    constructor Init(Hardware:TPlata; Channel:Integer);
    function GetVoltage: real; virtual;
    function isData: boolean;
    function isReady: boolean;
    procedure Measure;
    destructor Done; virtual;
    property U: real read FU write FU;
  end;

implementation

//==================================================

constructor TVoltmeter.Init(Hardware:TPlata; Channel:Integer);
var
  Ch:TLogicalCnannel;
begin
  Device := Hardware;
  ADC := TAdclevelsignal.Create(Device);
  Ch.Number := Channel;//Номер канала
  Ch.Repeating := 1;//режим циклических измерений
  Ch.InputRange := RANGE_3000mv; //3 вольта
  Ch.InputSwitch := INPUT_SIGNAL;//способ подключения
  ADC.ChannelLevel := Ch;
  ADC.Duration := 10;
  ADC.Frequency := 1000;
  ADC.Prepare;
  FU := 0;
end;

//--------------------------------------------------

procedure TVoltmeter.Measure;
var
  tmp: longint;
  range: integer;
begin
  ADC.Prepare;
  FU := ADC.GetLevelSignalInVolt * VoltageSplittingCoeficient;
end;

//--------------------------------------------------

function TVoltmeter.GetVoltage: real;
begin
  Measure;
  Result := FU;
end;

//--------------------------------------------------

function TVoltmeter.isData: boolean;
begin
  Result := True;
end;

//--------------------------------------------------

function TVoltmeter.isReady: boolean;
begin
  Result := True;
end;

//--------------------------------------------------

destructor TVoltmeter.Done;
begin
end;

//==================================================

end.{unit temp_s}
