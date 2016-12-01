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

Unit out_reg;

interface

Uses
  Basic, SysUtils;

type
  PTOutputRegister = ^TOutputRegister;
  TOutputRegister = class(TModule)
  protected
    procedure WriteData(NumberReg: byte; Data: longint);
    function ReadData(NumberReg: byte): longint;
  public
    constructor Init(NM: byte);
  end;

implementation

//==================================================

constructor TOutputRegister.Init(NM: byte);
begin
  inherited Init('TOutputRegistry', NM, CrateCannel);

  {$IF Defined(DEB)}
     while ReadData(0) <> 0 do WriteData(0, 0);
     while ReadData(0) <> 0 do WriteData(1, 0);
  {$IFEND}
end;

//--------------------------------------------------

procedure TOutputRegister.WriteData(NumberReg: byte; Data: longint);
begin
  SetA(NumberReg);
  Write24(16, Data);
  SetA(0);
end;

//--------------------------------------------------

function TOutputRegister.ReadData(NumberReg: byte): longint;
begin
     SetA(NumberReg);
     ReadData := Read24(0);
     SetA(0);
end;

//==================================================
end.