{************************************************************}
{                                                            }
{                 Модуль ХХХ                                 }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 26 ноября 2008                             }
{                                                            }
{************************************************************}
unit CompareFormModule;

interface

uses
  Spectrm, sp_unit, CommonTypes,
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, StdCtrls,
  ExtCtrls, TeeProcs, TeEngine, Chart, ComCtrls, Series,
  ToolWin, Buttons, Menus, CheckLst;

type
  TArraySpectrum = array of TSpectrum;
  TArrayChartSeries = array of TFastLineSeries;

  TCompareForm = class(TForm)
    ToolBar: TToolBar;
    SpeedButtonHS: TSpeedButton;
    SpeedButtonClose: TSpeedButton;
    SpeedButtonReload: TSpeedButton;
    PanelRight: TPanel;
    PanelLeft: TPanel;
    Splitter: TSplitter;
    Chart: TChart;
    CheckListBox: TCheckListBox;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButtonReloadClick(Sender: TObject);
    procedure SpeedButtonHSClick(Sender: TObject);
    procedure SpeedButtonCloseClick(Sender: TObject);
    procedure CheckListBoxClickCheck(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure ChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    FSpectrometer: TSpectrometer;
    FSpectrumBase: TSpectrumBase;
    FArraySpectrum: TArraySpectrum;
    FArrayChartSeries: TArrayChartSeries;

   // function GetLegend(StrT: String; StrF: String; StrA: String): String;
  public
    { Public declarations }
    property Spectrometer: TSpectrometer write FSpectrometer;
  end;


var
  CompareForm: TCompareForm;

implementation

{$R *.dfm}

//==================================================

{function TCompareForm.GetLegend(StrT: String; StrF: String; StrA: String): String;
var
  GetLegendStr: String;
  StrTemp, StrAngle, StrFreq: String;

begin
  GetLegendStr := '';
  if CheckBoxTemp.Checked then
    if FSpectrumBase <> nil then
    begin
      StrTemp := StrT + ' K';
      GetLegendStr := GetLegendStr + StrTemp;
    end
  else
    StrTemp := '';
  if CheckBoxFreq.Checked then
    if FSpectrumBase <> nil then
    begin
      StrFreq := StrF + ' GHz';
      GetLegendStr := GetLegendStr + ' ' + StrFreq;
    end
  else
    StrFreq := '';
  if CheckBoxAngle.Checked then
    if FSpectrumBase <> nil then
    begin
      StrAngle := StrA + ' deg';
      GetLegendStr := GetLegendStr + ' '+ StrAngle;
    end
  else
    StrAngle := '';
    GetLegend := GetLegendStr;
end;   }

//--------------------------------------------------

procedure TCompareForm.SpeedButtonCloseClick(Sender: TObject);
begin
  Close;
end;

//--------------------------------------------------

procedure TCompareForm.FormCreate(Sender: TObject);
begin
  CheckListBox.Clear;
  Chart.SeriesList.Clear;
  Randomize;
end;

//--------------------------------------------------

procedure TCompareForm.CheckListBoxClickCheck(Sender: TObject);
var
  StrStr: String;
  k: Integer;
  index: Integer;

begin
  index := CheckListBox.ItemIndex;
  if CheckListBox.Checked[index] then
  begin
    FArrayChartSeries[index].Active := True;
    Chart.Series[index].Clear;
    Chart.Series[index].SeriesColor := TColor(Random($FFFFFF));

    Chart.UndoZoom;
    //Для быстроты вывода спектра на экран чарта, сделаем разные циклы для передней и задней части импульса
    if FArraySpectrum[index].SpectrDescription.FrontBack = fbFront then
      for k := Low(FArraySpectrum[index].SpectrData) to High(FArraySpectrum[index].SpectrData) do
        Chart.SeriesList[index].AddXY(FArraySpectrum[index].SpectrData[k].X, FArraySpectrum[index].SpectrData[k].Y.Voltage,'');

    if FArraySpectrum[index].SpectrDescription.FrontBack = fbBack then
      for k := High(FArraySpectrum[index].SpectrData) downto Low(FArraySpectrum[index].SpectrData) do
        Chart.SeriesList[index].AddXY(FArraySpectrum[index].SpectrData[k].X, FArraySpectrum[index].SpectrData[k].Y.Voltage,'');
  end
  else
  begin
    if FArrayChartSeries[index] <> nil then
      FArrayChartSeries[index].Active := False;
  end; // CheckListBoxClickCheck
end;

//--------------------------------------------------

procedure TCompareForm.SpeedButtonReloadClick(Sender: TObject);
var
  StrName: String;
  legend: String;
  index0: Integer;
  FSpectrum: TSpectrum;
begin
  FSpectrumBase := FSpectrometer.SB;
  FSpectrumBase.BeginBase;
  index0 := 0;
  CheckListBox.Items.Clear;
  Chart.SeriesList.Clear;
  Chart.Repaint;
  Chart.Legend.Visible := False;
  if FSpectrumBase.Data <> nil then
  begin
    repeat
      FSpectrum := FSpectrumBase.Data.Content;
      with FSpectrum.SpectrDescription do
      begin
        StrName := '';
        if FrontBack = fbFront then
          StrName := IntToStr(FSpectrum.FileNumber) + '_front.dat'
        else
          StrName := IntToStr(FSpectrum.FileNumber) + '_back.dat';

        legend := ' T=' + FloatToStrF(Temperature, ffFixed, 5, 2, FormatSettings) +
          ' F=' + FloatToStrF(Frequency, ffFixed, 5, 2, FormatSettings) +
          ' A=' + FloatToStrF(Angle, ffFixed, 5, 2, FormatSettings);

        SetLength(FArraySpectrum, Length(FArraySpectrum) + 1);
        SetLength(FArrayChartSeries, Length(FArrayChartSeries) + 1);
        FArraySpectrum[index0] := FSpectrum;

        FArrayChartSeries[index0] := TFastLineSeries.Create(Self);
        FArrayChartSeries[index0].Active := False;
        FArrayChartSeries[index0].Title := legend;
        Chart.AddSeries(FArrayChartSeries[index0]);

        StrName := StrName + legend;
        CheckListBox.Items.Add(StrName);
        //CheckListBox.Items.
        inc(index0);
      end;
    until not FSpectrumBase.Up
  end;
end;

//--------------------------------------------------

procedure TCompareForm.SpeedButtonHSClick(Sender: TObject);
begin
  Chart.Legend.Visible := not Chart.Legend.Visible;
end;

//--------------------------------------------------

procedure TCompareForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    close;
end;

//--------------------------------------------------

procedure TCompareForm.FormShow(Sender: TObject);
begin
  CompareForm.WindowState := wsNormal;
  CompareForm.Width := 800;
  CompareForm.Height := 600;
end;

procedure TCompareForm.ChartMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  CX, CY: real;
  S: String;
begin
  if Chart.SeriesCount = 0 then
    exit;
  CX := Chart.Series[0].XScreenToValue(X);
  CY := Chart.Series[0].YScreenToValue(Y);

  Chart.Canvas.Pen.Color := clBlack;
  Chart.Canvas.Brush.Color := Chart.Color;
  Chart.Canvas.Font.Height := 14;
  Str(CX:5:2,S);
  Chart.Canvas.TextOut(10, 2, 'Поле = ' + S + ' кЭ');
  Str(CY:6:3,S);
  Chart.Canvas.TextOut(10, 16, 'Сигнал = ' + S);

end;

end.
