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
Unit mathematic;

interface

uses
  windows;

const
  ArrLength = 1000;

type
  PTRealPoint = ^TRealPoint;
  TRealPoint = record
    x: real;
    y: real;
  end;

  PTDataArray = ^TDataArray;
  TDataArray = array[1..ArrLength] of TRealPoint;

  PTLinearRegression = ^TLinearRegression;
  TLinearRegression = class
  private
    FSizeOfArray: word;
    FLineA: real;
    FLineB: real;
    FDeltaMax: real;
  public
    constructor Init(SizeofArray_: word);
    procedure GetLine(DataArray: PTDataarray);
    property SizeOfArray: word read FSizeOfArray write FSizeOfArray;
    property LineA: real read FLineA write FLineA;
    property LineB: real read FLineB write FLineB;
    property DeltaMax: real read FDeltaMax write FDeltaMax;
  end;



  TDataXY = array of Double;

function fitNewton(parameters: Pointer; XData: Pointer;//делает подгонку
  YData: Pointer; length: DWORD): integer; cdecl;
  external 'reg_dll.dll';

function func(parameters: Pointer; t :Double): Double cdecl;//возвращает поле
  external 'reg_dll.dll';

function diff(parameters: Pointer; t :Double): Double cdecl;//возвращает производную
  external 'reg_dll.dll';



implementation

//==================================================

{constructor MyTPoint.Init(x_, y_: real);
begin
  Fx := x_;
  Fy := y_;
end;}

//==================================================

constructor TLinearRegression.Init;
begin
  FSizeofArray := SizeofArray_;
  FDeltaMax := 0;
  FLineA := 0;
  FLineB := 1;
end;

//--------------------------------------------------

procedure TLinearRegression.GetLine;
var
  i: word;
  ySum, xSum, MeanX, Sum1, Sum2: real;
  delta: real;
begin
  ySum := 0;
  xSum := 0;
  for i := 1 to FSizeofArray do
  begin
    ySum := ySum + DataArray^[i].y;
    xSum := xSum + DataArray^[i].x;
  end;
  MeanX := xSum / FSizeOfArray;
  Sum1 := 0;
  Sum2 := 0;
  for i := 1 to FSizeofArray do
  begin
    Sum1 := Sum1 + DataArray^[i].y * (DataArray^[i].x - MeanX);
    Sum2 := Sum2 + sqr(DataArray^[i].x - MeanX);
  end;
  if Sum2 <> 0 then
    FLineB := Sum1 / Sum2
  else
  FLineB := 0;
  FLineA := 1 / FSizeOfArray * ySum - FLineB * MeanX;
  FDeltaMax := 0;
  for i := 1 to FSizeofArray do
  begin
    Delta := abs((FLineA + FLineB * DataArray^[i].x) - DataArray^[i].y);
    if Delta > FDeltaMax then
      FDeltaMax := Delta;
  end;
end;

end.