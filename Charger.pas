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
Unit Charger;

interface

uses
  Lcard, Basic, SysUtils;

type
  PTCharger = ^TCharger;
  TCharger = class(TObject)
  public
    constructor Init(Hardware: TPlata);
    procedure Charge;
    procedure UnCharge;
  private
    Device : TPlata;
  end;

implementation

//==================================================

constructor TCharger.Init(Hardware: TPlata);
begin
  Device := Hardware;
  Device.SetStateDigitalOutputRegisters(True); //Включаем цифровые выходы
  Device.Out($00);
end;

//--------------------------------------------------

procedure TCharger.Charge;
var
  i:word;
begin
  Device.Out(1);
  Sleep(100);
  Device.Out(0);
end;

//--------------------------------------------------

procedure TCharger.UnCharge;
begin
  Device.Out(8);
  Sleep(1);
  Device.Out(0);
end;

//==================================================

end.