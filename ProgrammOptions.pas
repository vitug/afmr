{************************************************************}
{                                                            }
{                 ������ ���                                 }
{       Copyright (c) 2001  ��� ����                         }
{               �����/������                                 }
{                                                            }
{  �����������: �� ��                                        }
{  �������������: 27 ������ 2008                             }
{                                                            }
{************************************************************}
unit ProgrammOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,
  sp_unit, CommonTypes, ExtCtrls;

type
  TFormOptions = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    ComboBoxAdcChannelField: TComboBox;
    ComboBoxAdcChannelSignal: TComboBox;
    Label3: TLabel;
    ComboBoxAdcChannelLevelSignal: TComboBox;
    Label4: TLabel;
    ComboBoxScaleField: TComboBox;
    Label5: TLabel;
    ComboBoxScaleSignal: TComboBox;
    GroupBoxField: TGroupBox;
    GroupBoxSignal: TGroupBox;
    GroupBoxLevelSignal: TGroupBox;
    Label6: TLabel;
    ComboBoxAdcSpectrFreq: TComboBox;
    Label7: TLabel;
    EditMeasureTime: TEdit;
    UpDownMeassureTime: TUpDown;
    Label8: TLabel;
    EditZeroLevel: TEdit;
    UpDownZeroLevel: TUpDown;
    Label10: TLabel;
    EditAmountSignal: TEdit;
    UpDownAmountSignal: TUpDown;
    ButtonOk: TButton;
    Label11: TLabel;
    EditAmountField: TEdit;
    UpDownAmountField: TUpDown;
    Label12: TLabel;
    ComboBoxScaleLevel: TComboBox;
    Label13: TLabel;
    EditAmountLevel: TEdit;
    UpDownAmountLevel: TUpDown;
    Label14: TLabel;
    ComboBoxDurationLevel: TComboBox;
    CheckBoxSaveParam: TCheckBox;
    Label9: TLabel;
    ComboBoxSwitchField: TComboBox;
    Label15: TLabel;
    ComboBoxSwitchSignal: TComboBox;
    Label16: TLabel;
    ComboBoxSwitchLevelSignal: TComboBox;
    Label17: TLabel;
    ComboBoxAdcLevelFreq: TComboBox;
    PageControl: TPageControl;
    TabSheetSpectr: TTabSheet;
    TabSheetLevel: TTabSheet;
    TabSheetBroach: TTabSheet;
    PanelButtons: TPanel;
    GroupBoxFrontPulse: TGroupBox;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    EditFrontK1: TEdit;
    EditFrontK2: TEdit;
    EditFrontK3: TEdit;
    GroupBoxBackPulse: TGroupBox;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    EditBackK1: TEdit;
    EditBackK2: TEdit;
    EditBackK3: TEdit;
    GroupBoxCircuitParam: TGroupBox;
    Label24: TLabel;
    EditResist: TEdit;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    EditInductance: TEdit;
    EditCapacity: TEdit;
    EditCoeffV0: TEdit;
    EditTau: TEdit;
    TabSheetDebug: TTabSheet;
    CheckBoxSaveADCData: TCheckBox;
    GroupBoxDebug: TGroupBox;
    Label29: TLabel;
    EditError: TEdit;
    Label30: TLabel;
    ComboBoxAutoGaugeScale: TComboBox;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSpectrometer: TSpectrometer;
    LastActivePage: TTabSheet;
    procedure UpdateForm;
    procedure SetParamToSpectrometr;
    procedure SaveParamBroach;
   public
    { Public declarations }
    property Spectrometer: TSpectrometer read FSpectrometer write FSpectrometer;
  end;

var
  FormOptions: TFormOptions;

implementation

uses Math;

{$R *.dfm}

//==================================================

procedure TFormOptions.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    FormOptions.Close;
end;

//-------------------------------------------------

procedure TFormOptions.FormActivate(Sender: TObject);
begin
  {----�������� ��������� ������ �� ������������-----}
  UpdateForm;
end;

//-------------------------------------------------

procedure TFormOptions.ButtonOkClick(Sender: TObject);
begin
  //��������� ����� ��������� ������������
  SetParamToSpectrometr;
  //�������� ��������� ���������
  LastActivePage := PageControl.ActivePage;
  // CloseForm
  FormOptions.Close;
end;

//-------------------------------------------------

procedure TFormOptions.UpdateForm;
begin
  //���� ���������� ���������� � �����
  CheckBoxSaveParam.Checked := FSpectrometer.IniFileParam.GetFlagSave;

  // ������ ��������  (������)
  PageControl.ActivePage := TabSheetSpectr;
  // ��������� ����
  ComboBoxAdcChannelField.ItemIndex := FSpectrometer.AdcSpectr.ChannelField.Number - 1;
  ComboBoxScaleField.ItemIndex := FSpectrometer.AdcSpectr.ChannelField.InputRange;
  ComboBoxSwitchField.ItemIndex := FSpectrometer.AdcSpectr.ChannelField.InputSwitch;
  EditAmountField.Text := IntToStr(FSpectrometer.AdcSpectr.ChannelField.Repeating);

  //������ ����������
  ComboBoxAdcChannelSignal.ItemIndex := FSpectrometer.AdcSpectr.ChannelSignal.Number - 1;
  ComboBoxScaleSignal.ItemIndex := FSpectrometer.AdcSpectr.ChannelSignal.InputRange;
  ComboBoxSwitchSignal.ItemIndex := FSpectrometer.AdcSpectr.ChannelSignal.InputSwitch;
  EditAmountSignal.Text := IntToStr(FSpectrometer.AdcSpectr.ChannelSignal.Repeating);

  //��������� ���������
  ComboBoxAdcSpectrFreq.ItemIndex := (FSpectrometer.AdcSpectr.Frequency div 1000) - 1;
  ComboBoxAdcLevelFreq.ItemIndex := (FSpectrometer.AdcLevel.Frequency div 1000) -1;
  EditMeasureTime.Text := IntToStr(FSpectrometer.AdcSpectr.Duration);

  // ������ ��������  (�������)
  PageControl.ActivePage := TabSheetLevel;
  //�������
  ComboBoxAdcChannelLevelSignal.ItemIndex := FSpectrometer.AdcLevel.ChannelLevel.Number - 1;
  ComboBoxScaleLevel.ItemIndex := FSpectrometer.AdcLevel.ChannelLevel.InputRange;
  ComboBoxSwitchLevelSignal.ItemIndex := FSpectrometer.AdcLevel.ChannelLevel.InputSwitch;
  ComboBoxDurationLevel.ItemIndex := (FSpectrometer.AdcLevel.Duration div 10) - 1;
  EditAmountLevel.Text := IntToStr(FSpectrometer.AdcLevel.ChannelLevel.Repeating);
  ComboBoxAutoGaugeScale.ItemIndex := (FSpectrometer.AutoGaugeScale div 10) - 1;


  //������ ��������  (���������)
  PageControl.ActivePage := TabSheetBroach;

  //������������ ���������� �� ������ ��������
  EditFrontK1.Text := FloatToStr(FSpectrometer.PulseGenerator.RiseUpCoefSet.k1, FormatSettings);
  EditFrontK2.Text := FloatToStr(FSpectrometer.PulseGenerator.RiseUpCoefSet.k2, FormatSettings);
  EditFrontK3.Text := FloatToStr(FSpectrometer.PulseGenerator.RiseUpCoefSet.k3, FormatSettings);

  //������������ ���������� �� ����� ��������
  EditBackK1.Text := FloatToStr(FSpectrometer.PulseGenerator.DownCoefSet.k1, FormatSettings);
  EditBackK2.Text := FloatToStr(FSpectrometer.PulseGenerator.DownCoefSet.k2, FormatSettings);
  EditBackK3.Text := FloatToStr(FSpectrometer.PulseGenerator.DownCoefSet.k3, FormatSettings);

  //��������� ��������� ����, ���� V0 � ������ ��������
  EditResist.Text := FloatToStr(FSpectrometer.PulseGenerator.BeginParamCircuit[prmR], FormatSettings);
  EditInductance.Text := FloatToStr(FSpectrometer.PulseGenerator.BeginParamCircuit[prmL], FormatSettings);
  EditCapacity.Text := FloatToStr(FSpectrometer.PulseGenerator.BeginParamCircuit[prmC], FormatSettings);
  EditCoeffV0.Text := FloatToStr(FSpectrometer.PulseGenerator.BeginParamCircuit[prmV0], FormatSettings);
  EditTau.Text := FloatToStr(FSpectrometer.PulseGenerator.BeginParamCircuit[prmT], FormatSettings);

  //�������� ������������ ������ ��� ��������
  EditError.Text := FloatToStr(FSpectrometer.PulseGenerator.MaxErrorFit, FormatSettings);

  //��������� ��������  (�������)
  PageControl.ActivePage := TabSheetDebug;

  //���� ���������� ���������� ������ � ���
  CheckBoxSaveADCData.Checked := FSpectrometer.SaveDebugADCData;

  //�� ���������
  PageControl.ActivePage := LastActivePage;
end;

//-------------------------------------------------

procedure TFormOptions.SetParamToSpectrometr;
var
  Channel: TLogicalCnannel;
begin
  with FSpectrometer do
  begin
    //���� ���������� ���������� � �����
    IniFileParam.SetFlagSave(CheckBoxSaveParam.Checked);

    //���� ���������� ���������� ������
    SaveDebugADCData := CheckBoxSaveADCData.Checked;
    if SaveDebugADCData then
      Files.CreateSubDirDebug;
    if CheckBoxSaveParam.Checked then
      IniFileParam.SetFlagSaveDebugADCData(CheckBoxSaveADCData.Checked);

    // ��������� ����
    with Channel do
    begin
      Number := ComboBoxAdcChannelField.ItemIndex + 1;
      InputRange := ComboBoxScaleField.ItemIndex;
      InputSwitch := ComboBoxSwitchField.ItemIndex;
      Repeating := StrToInt(EditAmountField.Text);
    end;
    AdcSpectr.ChannelField := Channel;
    if CheckBoxSaveParam.Checked then
      IniFileParam.SetParamChField(Channel);

    // ������ ����������
    with Channel do
    begin
      Number := ComboBoxAdcChannelSignal.ItemIndex + 1;
      InputRange := ComboBoxScaleSignal.ItemIndex;
      InputSwitch := ComboBoxSwitchSignal.ItemIndex;
      Repeating := StrToInt(EditAmountSignal.Text);
    end;
    AdcSpectr.ChannelSignal := Channel;
    if CheckBoxSaveParam.Checked then
      IniFileParam.SetParamChSignal(Channel);

    // �������
    with Channel do
    begin
      Number := ComboBoxAdcChannelLevelSignal.ItemIndex + 1;
      InputRange := ComboBoxScaleLevel.ItemIndex;
      InputSwitch := ComboBoxSwitchLevelSignal.ItemIndex;
      Repeating := StrToInt(EditAmountLevel.Text);
    end;
    AdcLevel.ChannelLevel := Channel;
    if CheckBoxSaveParam.Checked then
      IniFileParam.SetParamChLevel(Channel);

    // ���������� �������
    AutoGaugeScale := (ComboBoxAutoGaugeScale.ItemIndex + 1)* 10;
    if CheckBoxSaveParam.Checked then
      IniFileParam.SetAutoScalePercent(AutoGaugeScale);

    // ��������� ���������
    AdcSpectr.Frequency := (ComboBoxAdcSpectrFreq.ItemIndex + 1)* 1000;
    AdcLevel.Frequency := (ComboBoxAdcLevelFreq.ItemIndex + 1) * 1000;
    AdcSpectr.Duration := StrToInt(EditMeasureTime.Text);
    AdcLevel.Duration := (ComboBoxDurationLevel.ItemIndex + 1) * 10;

    if CheckBoxSaveParam.Checked then
    begin
      IniFileParam.SetAdcRate(AdcSpectr.Frequency);
      IniFileParam.SetRateAdcLevel(AdcLevel.Frequency);
      IniFileParam.SetDurationSpectr(AdcSpectr.Duration);
      IniFileParam.SetDurationLevel(AdcLevel.Duration);
    end;

    // ��������� ����� ��������� ���� � ������������� �����.
    SaveParamBroach;

    //���� ���� ��������� ��� ��� ������ ���������� ����� ���������
   if FSpectrometer.ReadyADC then
   begin
    AdcLevel.Prepare;
   end;

  end;
end;

//-------------------------------------------------

procedure TFormOptions.SaveParamBroach;
var
  CoefSet: TPulseEdgeCoefSet;
  Circuit: TParameters;
begin
  //������������ ���������� �� ������ ��������
  CoefSet.k1 := ConvertStringInFloat(EditFrontK1.Text);
  CoefSet.k2 := ConvertStringInFloat(EditFrontK2.Text);
  CoefSet.k3 := ConvertStringInFloat(EditFrontK3.Text);

  FSpectrometer.PulseGenerator.RiseUpCoefSet := CoefSet;
  if CheckBoxSaveParam.Checked then
    FSpectrometer.IniFileParam.SetRiseUpCoefSet(CoefSet);

  //������������ ���������� �� ����� ��������
  CoefSet.k1 := ConvertStringInFloat(EditBackK1.Text);
  CoefSet.k2 := ConvertStringInFloat(EditBackK2.Text);
  CoefSet.k3 := ConvertStringInFloat(EditBackK3.Text);

  FSpectrometer.PulseGenerator.DownCoefSet := CoefSet;
  if CheckBoxSaveParam.Checked then
    FSpectrometer.IniFileParam.SetDownCoefSet(CoefSet);

  //��������� ����, ���� V0 � ������ ��������
  Circuit[prmR] := ConvertStringInFloat(EditResist.Text);
  Circuit[prmL] := ConvertStringInFloat(EditInductance.Text);
  Circuit[prmC] := ConvertStringInFloat(EditCapacity.Text);
  Circuit[prmV0] := ConvertStringInFloat(EditCoeffV0.Text);
  Circuit[prmT] := ConvertStringInFloat(EditTau.Text);
  FSpectrometer.PulseGenerator.BeginParamCircuit := Circuit;
  if CheckBoxSaveParam.Checked then
    FSpectrometer.IniFileParam.SetParamCircuit(Circuit);

  //�������� ������������ ������������������ ������
  FSpectrometer.PulseGenerator.MaxErrorFit := ConvertStringInFloat(EditError.Text);
  if CheckBoxSaveParam.Checked then
    FSpectrometer.IniFileParam.SetMaxErrorFit(FSpectrometer.PulseGenerator.MaxErrorFit);
end;

//---------------------------------------------------

procedure TFormOptions.EditChange(Sender: TObject);
var
  F: double;
begin
  CheckOnNumber(TEdit(Sender), F);
end;


//==================================================
procedure TFormOptions.FormCreate(Sender: TObject);
begin
  LastActivePage := TabSheetSpectr;
end;

end.
