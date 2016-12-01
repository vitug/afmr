{************************************************************}
{                                                            }
{              Модуль Signal level Visualyzation             }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 23 ноября 2006                             }
{                                                            }
{************************************************************}
unit M_Gauge;

interface

uses
  Windows, Graphics,
  SysUtils, Classes, Math;

type
  TDrawType = (dtSolid, dtRect);

  TShowKind = (skVertical, skHorisontal);

  TSignalGauge = class
  private
    VisBuff : TBitmap;
    KindOrient  : TShowKind;
    BkgColor    : TColor;
    PenColor    : TColor;
    PeakColor   : TColor;
    FrmClear    : Boolean;
    UseBkg      : Boolean;
    ShowPeak    : Boolean;
    FMode       : Boolean;
    DrawRes     : Integer;
    SgnWidth    : Integer;
    SgnHeight   : Integer;
    GaugeWidh   : Integer;
    PeakFall    : Integer;
    LineFall    : Integer;
    ColHeight   : Integer;
    ColWidh     : Integer;
    SgnPeack    : Integer;
    SgnFallOff  : Integer;
    FFallOff    : Integer;
    FStep       : Integer;
    FNorma      : Integer;
  public
    constructor Create (Width, Height: Integer);
    procedure ResizeGauge(Width, Height: Integer);
    procedure ResetPeak;
    procedure Draw(HWND: THandle; Level: Real; X, Y: Integer);
    property BackColor: TColor read BkgColor write BkgColor;
    property Height: Integer read ColHeight write ColHeight;
    property Widh: Integer read ColWidh write ColWidh;
    property Pen: TColor read PenColor write PenColor;
    property Peak: TColor read PeakColor write PeakColor;
    property FrameClear: Boolean read FrmClear write FrmClear;
    property PeakFallOff: Integer read PeakFall write PeakFall;
    property LineFallOff: Integer read LineFall write LineFall;
    property DrawPeak: Boolean read ShowPeak write ShowPeak;
    property Opientation: TShowKind read KindOrient write KindOrient;
    property Scale: integer read FNorma write FNorma;
    property StepFallOff: Integer read FStep write FStep;
    property ModeStepFallOff: Boolean read FMode write FMode;
    property PeakValue: Integer read SgnPeack write SgnPeack;
  end;

  TGaugeGeneral = class
  private
    FWidth: integer;
    FHeight: Integer;
    FHandle: THandle;
    FLGauge: TSignalGauge;
	  FFactor: Real;          //множитель на которой умножается сигнал в вольтах перед выводом
  public
    constructor CreateGauge (aHand : THandle; aWidth, aHeight : Integer);
    procedure ShowLevel(L: real);
    procedure SetScale(NewScale: integer);
    property  LGauge: TSignalGauge read FLGauge write FLGauge;
  end;

implementation

uses
  main;

constructor TSignalGauge.Create(Width, Height: Integer);
begin
  VisBuff := TBitmap.Create;
  GaugeWidh := Width;
  VisBuff.Width := GaugeWidh;
  VisBuff.Height := Height;
  BkgColor := clBlack;
  SgnWidth := VisBuff.Width;
  SgnHeight := VisBuff.Height;
  PenColor := clAqua;
  PeakColor := clYellow;
  KindOrient := skHorisontal;
  DrawRes  := 1;
  FrmClear := True;
  UseBkg := False;
  PeakFall := 2;
  FMode := True;
  LineFall := 3;
  ColHeight := 10;
  ColWidh := 10;
  ShowPeak := True;
  FNorma := 1;
  FFallOff := LineFall;
  FStep := 3;
end;

//---------------------------------------------------

procedure TSignalGauge.ResizeGauge(Width, Height: Integer);
begin
  GaugeWidh := Width;
  VisBuff.Width := GaugeWidh;
  VisBuff.Height := Height;
  SgnWidth := VisBuff.Width;
  SgnHeight := VisBuff.Height;
end;

//---------------------------------------------------

procedure TSignalGauge.Draw(HWND: THandle; Level: real; X, Y: Integer);
var
  Xpos, Ypos : LongInt;
begin
  Xpos := 0;
  Ypos := 0;
  if KindOrient = skHorisontal then
  begin   //horisontal
    try
      Xpos := round((Level / Scale) * VisBuff.Width);
    except
      Xpos := round((Level) * VisBuff.Width);
    end;
    X := X - VisBuff.Width;
  end
  else
  begin  // if vertical
    try
      Ypos := round((Level / Scale) * VisBuff.Height);
    except
      Ypos := round((Level) * VisBuff.Height);
    end;
      X := X - VisBuff.Width;
  end;
  if FrmClear then
  begin
    VisBuff.Canvas.Pen.Color := BkgColor;
    VisBuff.Canvas.Brush.Color := BkgColor;
    VisBuff.Canvas.Rectangle(0, 0, VisBuff.Width, VisBuff.Height);
  end;
  VisBuff.Canvas.Pen.Color := PenColor;
  if KindOrient = skHorisontal then
  begin    //horisontal
    if XPos >= SgnWidth then
      XPos := SgnWidth - 1;
    if XPos >= SgnPeack then
      SgnPeack := XPos
    else
      SgnPeack := SgnPeack - PeakFall;
    if XPos + 1 >= SgnFallOff then
    begin
      SgnFallOff := XPos;
      FFallOff := SgnFallOff;
    end
    else
    begin  {коментарий указан в случае вертикально режима}
      if FMode then
        SgnFallOff := SgnFallOff - round((FFallOff - Xpos) / FStep)
      else
        SgnFallOff := SgnFallOff - LineFall;
    end;
  end
  else
  begin   // if vertical
    if YPos >= SgnHeight then
      YPos := SgnHeight - 1;
    if YPos >= SgnPeack then
      SgnPeack := YPos
    else SgnPeack := SgnPeack - PeakFall;
    if YPos + 1 >= SgnFallOff then
    begin
      SgnFallOff := YPos;
      FFallOff := SgnFallOff;
    end
    else
    begin
      if FMode then
      begin
        {Шаг, при котором число повторений,
         для установления индикатора в нужную озицию,
        определяется  равно переменной Step}
        SgnFallOff := SgnFallOff - round((FFallOff-Ypos)/FStep);
      end
      else
      begin
        {Шаг, при котором число повторений,
        для установления индикатора в нужную озицию,
        определяется независимой переменной LineFall}
        SgnFallOff := SgnFallOff - LineFall;
      end;
    end;
  end;

  // DRAW bar
  if ShowPeak then
    VisBuff.Canvas.Pen.Color := PeakColor;
  if KindOrient = skHorisontal then
  begin   //horisontal
    if ShowPeak then
      VisBuff.Canvas.MoveTo(X + VisBuff.Width + SgnPeack, Y + 1);
    if ShowPeak then
      VisBuff.Canvas.LineTo(X + VisBuff.Width +  SgnPeack, Y + 1 + ColHeight);
  end
  else
  begin  // if vertical
    if ShowPeak then
      VisBuff.Canvas.MoveTo(X + VisBuff.Width  , Y + VisBuff.Height- SgnPeack);
    if ShowPeak then
      VisBuff.Canvas.LineTo(X + VisBuff.Width +ColWidh , Y + VisBuff.Height - SgnPeack);
  end;
  VisBuff.Canvas.Pen.Color := PenColor;
  VisBuff.Canvas.Brush.Color := PenColor;
  if KindOrient = skHorisontal then
  begin   //horisontal
    VisBuff.Canvas.Rectangle(X + VisBuff.Width +  SgnFallOff, Y + 1,   X - VisBuff.Width , Y + 1 + ColHeight);
  end
  else
  begin   // if vertical
    VisBuff.Canvas.Rectangle(X + VisBuff.Width , Y + VisBuff.Height - SgnFallOff,   X + VisBuff.Width+ColWidh , Y + VisBuff.Height);
  end;

  BitBlt(HWND, 0, 0, VisBuff.Width, VisBuff.Height, VisBuff.Canvas.Handle, 0, 0, srccopy)
end;

//---------------------------------------------------

procedure TSignalGauge.ResetPeak;
begin
  SgnPeack := SgnFallOff;
end;

//==================================================

constructor TGaugeGeneral.CreateGauge (aHand : THandle; aWidth, aHeight : Integer);
begin
  FWidth := aWidth;
  FHeight := aHeight;
  FHandle := aHand;
  FLGauge := TSignalGauge.Create(FWidth, FHeight);
  //FAGauge := TAnalogGauge.InitAnalogGauge;
  FLGauge.Opientation := skVertical;
  FLGauge.Widh := FWidth;
  FLGauge.ModeStepFallOff := True;
  FLGauge.StepFallOff := 3;
  FLGauge.PeakFall := 0;
  FLGauge.Scale := 100; //шкала
  FFactor := 1000;      //вольты * 1000 = милливольты
end;

//---------------------------------------------------

procedure TGaugeGeneral.SetScale(NewScale: integer);
var
  tmp: integer;
begin
  tmp := FLGauge.Scale;
  if NewScale = 0 then
    NewScale := tmp;
  LGauge.Scale := NewScale;
end;

procedure TGaugeGeneral.ShowLevel(L: real);
begin
  LGauge.Draw(MainForm.PaintGauge.Canvas.Handle, L * FFactor, 0, 0);
end;

//==================================================


end.

