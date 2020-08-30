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
    Left = 644
    Top = 0
    Width = 390
    Height = 480
    Align = alClient
    Caption = 'PEIS'#20449#24687
    TabOrder = 1
    object DBGrid2: TDBGrid
      Left = 2
      Top = 15
      Width = 386
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
      Width = 386
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
          Width = 378
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
          Width = 378
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
    Width = 644
    Height = 480
    Align = alLeft
    Caption = #35774#22791#26816#26597#20449#24687
    TabOrder = 2
    object PageControl1: TPageControl
      Left = 2
      Top = 115
      Width = 640
      Height = 363
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = #32467#26524
        object DBGrid1: TDBGrid
          Left = 0
          Top = 0
          Width = 632
          Height = 335
          Align = alClient
          DataSource = DataSource1
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = ANSI_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #23435#20307
          TitleFont.Style = []
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
      Width = 640
      Height = 100
      Align = alTop
      TabOrder = 1
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 544
        Height = 16
        Caption = #27880':1'#12289#27599#27425#21457#36865#20026#35206#30422'('#38750#36861#21152')'#25805#20316','#22240#27492','#20165#25903#25345'1'#20010#21463#26816#32773'1'#24352#25253#21578#21333#30340#24773#20917
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
      object DBNavigator1: TDBNavigator
        Left = 144
        Top = 69
        Width = 192
        Height = 25
        DataSource = DataSource1
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
        TabOrder = 0
      end
      object BitBtn1: TBitBtn
        Left = 376
        Top = 69
        Width = 100
        Height = 25
        Caption = #21457#36865#21040'PEIS(F3)'
        TabOrder = 1
        OnClick = N1Click
      end
      object BitBtn2: TBitBtn
        Left = 8
        Top = 69
        Width = 75
        Height = 25
        Caption = #21047#26032
        TabOrder = 2
        OnClick = BitBtn2Click
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
      OnExecute = N1Click
    end
  end
end
