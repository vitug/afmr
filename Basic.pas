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

unit Basic;

interface

Uses
  SysUtils, Windows, Variants, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DB, DBClient, Provider, ExtCtrls;

const
  ThresholdV = 40E-3;
  LcardChannelAdcVoltage = 4; //Номер канала АЦП лкард для измерения напряжения заряда
  VoltageSplittingCoeficient = 400; //Коэффициент деления напряжения зарядв
  CodeFieldCoef = 0.134;{для меньшего коэффициента деления, для большего 0.134}
  r1 = 0.073;
  r2 = -4.81718E-5;
  l1 = 8.19396E-4;
  l2 = 1.44352E-8;
  v1 = 0.32048;
  v2 = 7.51734E-6;
  kappa = 0.11178;

function BinDectoBin(bd: word): word;
function BinDectoBin32(bd: longint): longint;
procedure Delay(ms: Cardinal);

var
  flagViewError: boolean;


implementation

uses
  Main;

//==================================================


//==================================================

function BinDectoBin(bd: word): word;
var
  cash, res: word;
  i, pow: integer;
begin
  pow:=1;
  res:=0;
  for i := 1 to 4 do
  begin
    cash := (bd shr ((i - 1) * 4));
    cash := (cash and $F);
    if cash > 10 then
    begin
      res := 10001;
      break;
    end;
    res := res + cash * pow;
    pow := pow * 10;
  end;
  Result := res;
end;

//==================================================

function BinDectoBin32(bd: longint): longint;
var
   cash, res: longint;
   i, pow: integer;
begin
  pow := 1;
  res := 0;
  for i := 1 to 8 do
  begin
    cash := (bd shr ((i - 1) * 4));
    cash := (cash and $F);
    if cash > 10 then
    begin
      res := 10001;
      break;
   end;
   res := res + cash * pow;
   pow := pow * 10;
 end;
 Result := res;
end;

//==================================================

procedure Delay(ms: Cardinal);
var
  h: THandle;
begin
  h := CreateEvent(nil, true, false, 'et');
  WaitForSingleObject(h, ms);
  CloseHandle(h);
end;

//==================================================

end.

