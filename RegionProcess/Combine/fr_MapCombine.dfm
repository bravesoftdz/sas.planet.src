object frMapCombine: TfrMapCombine
  Left = 0
  Top = 0
  Width = 535
  Height = 304
  Align = alClient
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object pnlTargetFile: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 25
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 0
    object lblTargetFile: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 41
      Height = 19
      Margins.Left = 0
      Margins.Top = 0
      Align = alLeft
      Caption = 'Save to:'
      Layout = tlCenter
      ExplicitHeight = 13
    end
    object edtTargetFile: TEdit
      Left = 47
      Top = 3
      Width = 464
      Height = 19
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 21
    end
    object btnSelectTargetFile: TButton
      Left = 511
      Top = 3
      Width = 21
      Height = 19
      Align = alRight
      Caption = '...'
      TabOrder = 1
      OnClick = btnSelectTargetFileClick
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 150
    Width = 535
    Height = 154
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 135
    ExplicitHeight = 169
    object pnlOptions: TPanel
      Left = 0
      Top = 0
      Width = 210
      Height = 154
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 3
      Constraints.MinHeight = 80
      Constraints.MinWidth = 210
      TabOrder = 0
      ExplicitHeight = 169
      object chkUseMapMarks: TCheckBox
        Left = 3
        Top = 54
        Width = 204
        Height = 17
        Align = alTop
        Caption = 'Add visible placemarks'
        TabOrder = 0
      end
      object chkUseRecolor: TCheckBox
        Left = 3
        Top = 20
        Width = 204
        Height = 17
        Align = alTop
        Caption = 'Use postprocessing settings'
        TabOrder = 1
      end
      object flwpnlJpegQuality: TFlowPanel
        Left = 3
        Top = 71
        Width = 204
        Height = 25
        Align = alTop
        AutoSize = True
        AutoWrap = False
        BevelOuter = bvNone
        Constraints.MinHeight = 25
        Padding.Top = 2
        TabOrder = 2
        object lblJpgQulity: TLabel
          AlignWithMargins = True
          Left = 0
          Top = 5
          Width = 52
          Height = 13
          Margins.Left = 0
          Margins.Right = 5
          Alignment = taRightJustify
          Caption = 'Quality, %'
          Layout = tlCenter
        end
        object seJpgQuality: TSpinEdit
          Left = 57
          Top = 2
          Width = 53
          Height = 22
          MaxValue = 100
          MinValue = 1
          TabOrder = 0
          Value = 95
        end
      end
      object chkPngWithAlpha: TCheckBox
        Left = 3
        Top = 3
        Width = 204
        Height = 17
        Align = alTop
        Caption = 'Save PNG with alpha channel'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object chkSaveGeoRefInfoToJpegExif: TCheckBox
        Left = 3
        Top = 37
        Width = 204
        Height = 17
        Align = alTop
        Caption = 'Save GeoRef info to Exif'
        TabOrder = 4
      end
    end
    object pnlPrTypes: TPanel
      Left = 210
      Top = 0
      Width = 157
      Height = 154
      Align = alRight
      BevelOuter = bvNone
      BorderWidth = 3
      Constraints.MinWidth = 157
      TabOrder = 1
      ExplicitHeight = 169
      object lblPrTypes: TLabel
        Left = 3
        Top = 3
        Width = 151
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = 'Create georeferencing file:'
        WordWrap = True
      end
      object chklstPrTypes: TCheckListBox
        Left = 3
        Top = 18
        Width = 151
        Height = 133
        Align = alClient
        ItemHeight = 13
        Items.Strings = (
          '.map'
          '.tab'
          '.w'
          '.dat'
          '.kml')
        TabOrder = 0
        ExplicitHeight = 148
      end
    end
    object pnlSplit: TPanel
      Left = 367
      Top = 0
      Width = 168
      Height = 154
      Align = alRight
      BevelOuter = bvNone
      BorderWidth = 3
      Constraints.MinHeight = 71
      Constraints.MinWidth = 168
      TabOrder = 2
      ExplicitHeight = 169
      object grpSplit: TGroupBox
        Left = 3
        Top = 3
        Width = 162
        Height = 63
        Align = alTop
        Caption = 'Split image'
        TabOrder = 0
        object lblSplitHor: TLabel
          Left = 7
          Top = 16
          Width = 59
          Height = 13
          Caption = 'horizontally:'
        end
        object lblSplitVert: TLabel
          AlignWithMargins = True
          Left = 7
          Top = 40
          Width = 47
          Height = 13
          Caption = 'vertically:'
        end
        object seSplitHor: TSpinEdit
          Left = 106
          Top = 13
          Width = 47
          Height = 22
          MaxValue = 1000
          MinValue = 1
          TabOrder = 0
          Value = 1
        end
        object seSplitVert: TSpinEdit
          Left = 106
          Top = 37
          Width = 47
          Height = 22
          MaxValue = 1000
          MinValue = 1
          TabOrder = 1
          Value = 1
        end
      end
    end
  end
  object pnlMapSelect: TPanel
    Left = 0
    Top = 25
    Width = 535
    Height = 125
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 2
    object lblStat: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 110
      Width = 529
      Height = 13
      Align = alBottom
      Caption = '_'
      Layout = tlCenter
      ExplicitTop = 92
      ExplicitWidth = 6
    end
    object pnlZoom: TPanel
      Left = 464
      Top = 0
      Width = 71
      Height = 107
      Align = alRight
      Alignment = taLeftJustify
      BevelEdges = []
      BevelKind = bkTile
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitHeight = 81
      object Labelzoom: TLabel
        AlignWithMargins = True
        Left = 3
        Top = -2
        Width = 30
        Height = 13
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Caption = 'Zoom:'
      end
      object cbbZoom: TComboBox
        Left = 1
        Top = 11
        Width = 67
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbbZoomChange
      end
    end
    object pnlMapFrame: TPanel
      Left = 3
      Top = -2
      Width = 455
      Height = 40
      Align = alCustom
      Alignment = taLeftJustify
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 1
      object lblMapCaption: TLabel
        Left = 0
        Top = 0
        Width = 455
        Height = 13
        Margins.Left = 0
        Margins.Top = 0
        Align = alTop
        Caption = 'Map:'
        ExplicitWidth = 24
      end
    end
    object pnlLayerFrame: TPanel
      Left = 3
      Top = 38
      Width = 455
      Height = 40
      Align = alCustom
      Alignment = taLeftJustify
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 2
      object lblLayerCaption: TLabel
        Left = 0
        Top = 0
        Width = 455
        Height = 13
        Margins.Left = 0
        Margins.Top = 0
        Align = alTop
        Caption = 'Overlay layer:'
        ExplicitWidth = 69
      end
    end
    object pnlProjection: TPanel
      Left = 0
      Top = 80
      Width = 535
      Height = 21
      Align = alCustom
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 3
      object lblProjection: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 0
        Width = 52
        Height = 19
        Margins.Top = 0
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Projection:'
        Layout = tlCenter
        ExplicitLeft = 0
        ExplicitHeight = 13
      end
      object cbbProjection: TComboBox
        Left = 63
        Top = 0
        Width = 469
        Height = 21
        Align = alCustom
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object dlgSaveTargetFile: TSaveDialog
    DefaultExt = 'zip'
    Filter = 'Zip |*.zip'
    Left = 120
    Top = 128
  end
end