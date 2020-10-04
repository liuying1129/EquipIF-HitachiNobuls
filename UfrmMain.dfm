object frmMain: TfrmMain
  Left = 193
  Top = 118
  Width = 1050
  Height = 538
  Caption = 'HitachiNoblus->PEIS'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 480
    Width = 1034
    Height = 19
    Panels = <
      item
        Text = #35774#22791
        Width = 30
      end
      item
        Width = 400
      end
      item
        Width = 35
      end
      item
        Width = 50
      end>
  end
  object GroupBox1: TGroupBox
    Left = 674
    Top = 0
    Width = 360
    Height = 480
    Align = alClient
    Caption = 'PEIS'#20449#24687
    TabOrder = 1
    object DBGrid2: TDBGrid
      Left = 2
      Top = 15
      Width = 356
      Height = 150
      Align = alTop
      DataSource = DataSource2
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #23435#20307
      TitleFont.Style = []
    end
    object PageControl2: TPageControl
      Left = 2
      Top = 165
      Width = 356
      Height = 313
      ActivePage = TabSheet4
      Align = alClient
      TabOrder = 1
      object TabSheet3: TTabSheet
        Caption = #32467#26524
        object DBGrid3: TDBGrid
          Left = 0
          Top = 0
          Width = 318
          Height = 310
          Align = alClient
          DataSource = DataSource3
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = ANSI_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #23435#20307
          TitleFont.Style = []
        end
      end
      object TabSheet4: TTabSheet
        Caption = #32467#26524#35814#24773
        ImageIndex = 1
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 348
          Height = 40
          Align = alTop
          TabOrder = 0
          object Label2: TLabel
            Left = 208
            Top = 14
            Width = 52
            Height = 13
            Caption = #39033#30446#25552#31034
            Font.Charset = GB2312_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object DBNavigator2: TDBNavigator
            Left = 8
            Top = 8
            Width = 192
            Height = 25
            DataSource = DataSource3
            VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
            TabOrder = 0
          end
        end
        object Memo2: TMemo
          Left = 0
          Top = 40
          Width = 348
          Height = 245
          Align = alClient
          ReadOnly = True
          TabOrder = 1
        end
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 0
    Width = 674
    Height = 480
    Align = alLeft
    Caption = #35774#22791#26816#26597#20449#24687
    TabOrder = 2
    object PageControl1: TPageControl
      Left = 2
      Top = 161
      Width = 670
      Height = 317
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = #32467#26524
        object DBGrid1: TDBGrid
          Left = 0
          Top = 0
          Width = 662
          Height = 289
          Align = alClient
          DataSource = DataSource1
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = ANSI_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #23435#20307
          TitleFont.Style = []
          OnCellClick = DBGrid1CellClick
          OnDrawColumnCell = DBGrid1DrawColumnCell
        end
      end
      object TabSheet2: TTabSheet
        Caption = #32467#26524#35814#24773
        ImageIndex = 1
        object Memo1: TMemo
          Left = 0
          Top = 0
          Width = 628
          Height = 370
          Align = alClient
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object Panel1: TPanel
      Left = 2
      Top = 15
      Width = 670
      Height = 146
      Align = alTop
      TabOrder = 1
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 464
        Height = 16
        Caption = #27880':1'#12289#23545#20110#21457#36865#25805#20316','#26816#26597#25552#31034#20026#35206#30422#26041#24335','#32467#35770#12289#24314#35758#20026#36861#21152#26041#24335
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 31
        Top = 28
        Width = 328
        Height = 16
        Caption = '2'#12289#36890#36807#22995#21517#12289#24180#40836#12289#24615#21035#21305#37197'PEIS'#20013#30340#21463#26816#32773
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object Label4: TLabel
        Left = 31
        Top = 48
        Width = 600
        Height = 16
        Caption = '3'#12289#32467#35770#29983#25104#35268#21017':'#20013#25991#21477#21495#12289#20998#21495#23558#26816#26597#25552#31034#20998#27573','#19981#21547'"'#26410#35265#26126#26174#24322#24120'"'#30340#25552#31034#20026#32467#35770
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object Label5: TLabel
        Left = 31
        Top = 68
        Width = 248
        Height = 16
        Caption = '4'#12289#21463#26816#32773#22995#21517#20026#32418#33394#34920#31034#21457#36865#25104#21151
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object SpeedButton1: TSpeedButton
        Left = 414
        Top = 119
        Width = 35
        Height = 22
        Caption = #20840#36873
        OnClick = SpeedButton1Click
      end
      object SpeedButton2: TSpeedButton
        Left = 449
        Top = 119
        Width = 45
        Height = 22
        Caption = #20840#19981#36873
        OnClick = SpeedButton2Click
      end
      object Label6: TLabel
        Left = 155
        Top = 93
        Width = 13
        Height = 13
        Caption = #33267
      end
      object Label7: TLabel
        Left = 7
        Top = 93
        Width = 52
        Height = 13
        Caption = #21019#24314#26102#38388
      end
      object DBNavigator1: TDBNavigator
        Left = 60
        Top = 117
        Width = 192
        Height = 25
        DataSource = DataSource1
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
        TabOrder = 0
      end
      object BitBtn1: TBitBtn
        Left = 414
        Top = 87
        Width = 100
        Height = 25
        Caption = #21457#36865#21040'PEIS(F3)'
        TabOrder = 1
        OnClick = BitBtn1Click
      end
      object DateTimePicker1: TDateTimePicker
        Left = 60
        Top = 90
        Width = 95
        Height = 21
        Date = 44117.382772129630000000
        Time = 44117.382772129630000000
        TabOrder = 2
        OnChange = DateTimePicker1Change
      end
      object DateTimePicker2: TDateTimePicker
        Left = 170
        Top = 90
        Width = 95
        Height = 21
        Date = 44117.382772129630000000
        Time = 44117.382772129630000000
        TabOrder = 3
        OnChange = DateTimePicker2Change
      end
      object LabeledEdit1: TLabeledEdit
        Left = 329
        Top = 90
        Width = 70
        Height = 21
        Hint = #22238#36710#26597#35810
        EditLabel.Width = 52
        EditLabel.Height = 13
        EditLabel.Caption = #36865#26816#21307#29983
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnKeyDown = LabeledEdit1KeyDown
      end
    end
  end
  object ADOConnPEIS: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 502
    Top = 18
  end
  object ADOConnEquip: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 534
    Top = 18
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 64
    Top = 182
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnEquip
    AfterOpen = ADOQuery1AfterOpen
    AfterScroll = ADOQuery1AfterScroll
    Parameters = <>
    Left = 96
    Top = 182
  end
  object ADOQuery2: TADOQuery
    Connection = ADOConnPEIS
    AfterOpen = ADOQuery2AfterOpen
    AfterScroll = ADOQuery2AfterScroll
    Parameters = <>
    Left = 864
    Top = 64
  end
  object DataSource2: TDataSource
    DataSet = ADOQuery2
    Left = 832
    Top = 64
  end
  object DataSource3: TDataSource
    DataSet = ADOQuery3
    Left = 808
    Top = 184
  end
  object ADOQuery3: TADOQuery
    Connection = ADOConnPEIS
    AfterOpen = ADOQuery3AfterOpen
    AfterScroll = ADOQuery3AfterScroll
    Parameters = <>
    Left = 840
    Top = 184
  end
  object ActionList1: TActionList
    Left = 570
    Top = 18
    object Action1: TAction
      Caption = 'Action1'
      ShortCut = 114
    end
  end
end
