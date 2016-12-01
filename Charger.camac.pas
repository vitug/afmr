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
  Out_reg, Basic, SysUtils;

type
  PTCharger = ^TCharger;
  TCharger = class(TOutputRegister)
  public
    constructor Init;
    procedure Charge;
    procedure UnCharge;
  end;

implementation

//==================================================

constructor TCharger.Init;
begin
  inherited Init(SiteOutputReg);
end;

//--------------------------------------------------

procedure TCharger.Charge;
var
  i:word;
begin
  i := 1;
  repeat
    Writedata(1, $4);
    i := i + 1;
  until (i = 500);
  WriteData(1, $4);
  Delay(200);
  WriteData(1, $0);
  Delay(100);
  WriteData(1, $0);
end;

//--------------------------------------------------

procedure TCharger.UnCharge;
begin
  WriteData(1, $2);
  WriteData(1, 0);
end;

//==================================================

end.