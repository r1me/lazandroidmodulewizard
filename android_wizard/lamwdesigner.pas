unit LamwDesigner;

{$mode objfpc}{$h+}

interface

uses
  Classes, SysUtils, Graphics, Controls, FormEditingIntf, PropEdits,
  ComponentEditors, ProjectIntf, Laz2_DOM, AndroidWidget, Laz_And_Controls,
  Dialogs, Forms, AndroidThemes, ImgCache,  LCLVersion;

type
  TDraftWidget = class;

  jVisualControlClass = class of jVisualControl;
  TDraftWidgetClass = class of TDraftWidget;

  { TDraftControlHash }

  TDraftControlHash = class
  private
    FFreeLeft: Integer;
    FItems: array of record
      VisualControl: jVisualControlClass;
      Draft: TDraftWidgetClass;
    end;
    function Hash1(c: TClass): PtrUInt; inline;
    function Hash2(i: PtrUInt): PtrUInt; inline;
  public
    constructor Create(MaxCapacity: Integer);
    procedure Add(VisualControlClass: jVisualControlClass; DraftWidgetClass: TDraftWidgetClass);
    function Find(VisualControlClass: TClass): TDraftWidgetClass;
  end;

  { TAndroidWidgetMediator :: thanks to x2nie !}

  TAndroidWidgetMediator = class(TDesignerMediator,IAndroidWidgetDesigner)
  private
    FDefaultBrushColor: TColor;
    FDefaultPenColor: TColor;
    FDefaultFontColor: TColor;
    FImageCache: TImageCache;
    FSizing: Boolean;
    FStarted, FDone, FCustomDialogs, FShownCustomDialogs: TFPList;
    FLastSelectedContainer: jVisualControl;
    FSelection: TFPList;
    FProjFile: TLazProjectFile;
    FjControlDeleted: Boolean;
    FTheme: TAndroidTheme;

    function GetAndroidForm: jForm;

    //Smart Designer helpers
    procedure InitSmartDesignerHelpers;
    procedure UpdateJControlsList; inline;

  protected
    //procedure OnDesignerModified(Sender: TObject);
    procedure OnDesignerModified(Sender: TObject{$If lcl_fullversion=1070000}; {%H-}PropName: ShortString{$ENDIF});
    procedure OnPersistentAdded(APersistent: TPersistent; {%H-}Select: boolean);
    procedure OnPersistentDeleted;
    procedure OnPersistentDeleting(APersistent: TPersistent);
    procedure OnSetSelection(const ASelection: TPersistentSelectionList);
    // tk
    procedure OnAutoAssignIDs(Sender: TObject);
    procedure SetRoot(const AValue: TComponent); override;
    // end tk
  public

    //needed by the lazarus form editor
    class function CreateMediator(TheOwner, TheForm: TComponent): TDesignerMediator; override;
    class function FormClass: TComponentClass; override;

    procedure GetBounds(AComponent: TComponent; out CurBounds: TRect); override;
    procedure SetBounds(AComponent: TComponent; NewBounds: TRect); override;
    procedure GetClientArea(AComponent: TComponent; out CurClientArea: TRect; out ScrollOffset: TPoint); override;
    procedure InitComponent(AComponent, NewParent: TComponent; NewBounds: TRect); override;
    procedure Paint; override;
    function ComponentIsIcon(AComponent: TComponent): boolean; override;
    function ComponentIsVisible(AComponent: TComponent): Boolean; override;
    function ParentAcceptsChild(Parent: TComponent; Child: TComponentClass): boolean; override;
    procedure UpdateTheme;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; p: TPoint; var Handled: boolean); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; p: TPoint; var Handled: boolean); override;
    procedure MouseMove(Shift: TShiftState; p: TPoint; var Handled: boolean); override;

  public
    // needed by TAndroidWidget
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
    function AssetsDir: string;
    property AndroidForm: jForm read GetAndroidForm;
    property AndroidTheme: TAndroidTheme read FTheme;
    property ImageCache: TImageCache read FImageCache;
  public
    procedure GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer); override;
  end;


  { TDraftWidget }

  TDraftWidget = class
  private
    FColor: TARGBColorBridge;
    FFontColor: TARGBColorBridge;
    BaseStyle: string;
    lpHeight, lpWidth: TLayoutParams;
    procedure SetColor(AColor: TARGBColorBridge);
    procedure SetFontColor(AColor: TARGBColorBridge);
    function Designer: TAndroidWidgetMediator;
    function WrapContentHeightByChildren: Integer;
    function WrapContentWidthByChildren: Integer;
  protected
    FAndroidWidget: TAndroidWidget;      // original
    FCanvas: TCanvas;                    // canvas to draw onto
    FLeftTop, FRightBottom: TPoint;      // layout
    FMinWidth, FMinHeight: Integer;
    function GetParentBackgroundColor: TARGBColorBridge;
    function GetBackGroundColor: TColor;
    function DefaultTextColor: TColor; virtual;
    function GetNewWidth: Integer;
    function GetNewHeight: Integer;
    procedure SetBounds;
  public
    BackGroundColor: TColor;
    TextColor: TColor;
    MarginBottom: integer;
    MarginLeft: integer;
    MarginRight: integer;
    MarginTop: integer;
    Height: integer;
    Width: integer;
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); virtual;
    procedure Draw; virtual;
    procedure UpdateLayout; virtual;
    property Color: TARGBColorBridge read FColor write SetColor;
    property FontColor: TARGBColorBridge read FFontColor write SetFontColor;
  end;

  { TDraftTextView }

  TDraftTextView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftEditText }

  TDraftEditText = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftAutoTextView }

  TDraftAutoTextView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftButton }

  TDraftButton = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftCheckBox }

  TDraftCheckBox = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftRadioButton }

  TDraftRadioButton = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftRadioGroup }

  TDraftRadioGroup = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftRatingBar }

  TDraftRatingBar = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  TDraftDigitalClock = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  TDraftAnalogClock = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  { TDraftProgressBar }

  TDraftProgressBar = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  TDraftSeekBar = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftListView }

  TDraftListView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftImageBtn }

  TDraftImageBtn = class(TDraftWidget)
  private
    FImage: TPortableNetworkGraphic;
    function GetImage: TPortableNetworkGraphic;
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftImageView }

  TDraftImageView = class(TDraftWidget)
  private
    FImage: TPortableNetworkGraphic;
    function GetImage: TPortableNetworkGraphic;
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  {TDraftDrawingView}

  TDraftDrawingView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  {TDraftSurfaceView}

  TDraftSurfaceView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  { TDraftSpinner }

  TDraftSpinner = class(TDraftWidget)
  private
    FDropListTextColor: TARGBColorBridge;
    DropListFontColor: TColor;

    FDropListBackgroundColor: TARGBColorBridge;
    DropListColor: TColor;

    FSelectedFontColor: TARGBColorBridge;
    SelectedTextColor: TColor;

    procedure SetDropListTextColor(Acolor: TARGBColorBridge);
    procedure SetDropListBackgroundColor(Acolor: TARGBColorBridge);
    procedure SetSelectedFontColor(Acolor: TARGBColorBridge);

  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;

    property DropListTextColor: TARGBColorBridge read FDropListTextColor write SetDropListTextColor;
    property DropListBackgroundColor: TARGBColorBridge  read FDropListBackgroundColor write SetDropListBackgroundColor;
    property SelectedFontColor: TARGBColorBridge  read FSelectedFontColor write SetSelectedFontColor;
  end;

  { TDraftWebView }

  TDraftWebView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftScrollView }

  TDraftScrollView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  TDraftHorizontalScrollView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftToggleButton }

  TDraftToggleButton = class(TDraftWidget)
  private
    FOnOff: boolean;
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftSwitchButton }

  TDraftSwitchButton = class(TDraftWidget)
  public
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftGridView }

  TDraftGridView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftView }

  TDraftView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  { TDraftPanel }

  TDraftPanel = class(TDraftWidget)
  public
    procedure Draw; override;
  end;


  { TARGBColorBridgePropertyEditor }

  TARGBColorBridgePropertyEditor = class(TEnumPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    procedure ListDrawValue(const CurValue: ansistring; Index: integer;
      ACanvas: TCanvas; const ARect:TRect; AState: TPropEditDrawState); override;
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      {%H-}AState: TPropEditDrawState); override;
  end;

  { TAnchorPropertyEditor }

  TAnchorPropertyEditor = class(TPersistentPropertyEditor)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  { TImageListPropertyEditor
    Only jImageList from the same form can be used }

  TImageListPropertyEditor = class(TPersistentPropertyEditor)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  { TAndroidFormSizeComponentEditor }

  TAndroidFormSizeComponentEditor = class(TDefaultComponentEditor)
  private
    procedure ChangeSize(AWidth, AHeight: Integer);
    procedure ShowSelectSizeDialog;
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  { TAndroidFormSizePropertyEditor }

  TAndroidFormSizePropertyEditor = class(TIntegerPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  { TjImageListImagesEditor }

  TjImageListImagesEditor = class(TClassPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  { TjImageListEditor }

  TjImageListEditor = class(TComponentEditor)
  public
    procedure Edit; override;
    procedure ExecuteVerb({%H-}Index: Integer); override;
    function GetVerb({%H-}Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  { TImageIndexPropertyEditor }

  TImageIndexPropertyEditor = class(TIntegerPropertyEditor)
  private
    FAssetsPath: string;
    FImageCache: TImageCache;
    FImages: jImageList;
    function GetImageList: jImageList;
    procedure GetAssets;
  public
    procedure Activate; override;
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const NewValue: ansistring); override;
    procedure ListDrawValue(const CurValue: ansistring; Index:integer;
      ACanvas: TCanvas;  const ARect: TRect; AState: TPropEditDrawState); override;
  end;

  { TjCustomDialogComponentEditor }

  TjCustomDialogComponentEditor = class(TComponentEditor)
  public
    function GetVerbCount: Integer; override;
    function GetVerb({%H-}Index: Integer): string; override;
    procedure ExecuteVerb({%H-}Index: Integer); override;
  end;

implementation

uses
  LCLIntf, LCLType, strutils, ObjInspStrConsts, IDEMsgIntf, LazIDEIntf,
  IDEExternToolIntf, laz2_XMLRead, LazFileUtils, FPimage, typinfo,
  uFormSizeSelect, LamwSettings, SmartDesigner, jImageListEditDlg,
  customdialog, togglebutton, switchbutton,
  Laz_And_GLESv1_Canvas, Laz_And_GLESv2_Canvas, gridview, Spinner, seekbar,
  radiogroup, ratingbar, digitalclock, analogclock, surfaceview,
  autocompletetextview, drawingview, chronometer, viewflipper, videoview;

var
  DraftClassesMap: TDraftControlHash;

procedure GetRedGreenBlue(rgb: longInt; out Red, Green, Blue: word); inline;
begin
  Red   := ( (rgb and $ff0000)  shr 16);
  Red   := Red shl 8 or Red;
  Green := ( (rgb and $ff00  )  shr  8);
  Green := Green shl 8 or Green;
  Blue  := ( (rgb and $ff    )        );
  Blue  := Blue shl 8 or Blue;
end;

function ToTFPColor(colbrColor: TARGBColorBridge): TFPColor;
var
  index: integer;
  red, green, blue: word;
begin
  index := Ord(colbrColor);
  GetRedGreenBlue(TFPColorBridgeArray[index], red, green, blue);
  Result.Red   := red;
  Result.Green := green;
  Result.Blue  := blue;
  Result.Alpha := AlphaOpaque;
end;

function ToTColor(colbrColor: TARGBColorBridge): TColor; inline;
begin
  // note: it can be done in more efficient way, but...
  Result := FPColorToTColor(ToTFPColor(colbrColor));
end;

function AndroidToLCLFontSize(asize: DWord; Default: Integer): Integer; inline;
begin
  case asize of
  0: Result := Default;
  1: Result := 1;
  else Result := asize * 3 div 4;
  end;
end;

function BlendColors(c: TColor; alpha: Double; r, g, b: Byte): TColor; inline;
var
  r1, g1, b1: Byte;
begin
  RedGreenBlue(ColorToRGB(c), r1, g1, b1);
  Result := RGBToColor(Byte(Trunc(r1 * alpha + r * (1 - alpha))),
                       Byte(Trunc(g1 * alpha + g * (1 - alpha))),
                       Byte(Trunc(b1 * alpha + b * (1 - alpha))));
end;

procedure RegisterAndroidWidgetDraftClass(AWidgetClass: jVisualControlClass;
  ADraftClass: TDraftWidgetClass);
begin
  DraftClassesMap.Add(AWidgetClass, ADraftClass);
end;

{ TjCustomDialogComponentEditor }

function TjCustomDialogComponentEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TjCustomDialogComponentEditor.GetVerb(Index: Integer): string;
begin
  with ((Component.Owner as TAndroidForm).Designer as TAndroidWidgetMediator) do
    if ComponentIsIcon(Self.Component) then
      Result := 'Show custom dialog'
    else
      Result := 'Hide custom dialog';
end;

procedure TjCustomDialogComponentEditor.ExecuteVerb(Index: Integer);
var
  i, maxH: Integer;
begin
  with ((Component.Owner as TAndroidForm).Designer as TAndroidWidgetMediator) do
  begin
    i := FShownCustomDialogs.IndexOf(Component);
    if i >= 0 then
    begin
      FShownCustomDialogs.Delete(i);
      TAndroidWidget(Component).Left := LeftFromDesignInfo(Component.DesignInfo);
      TAndroidWidget(Component).Top := TopFromDesignInfo(Component.DesignInfo);
    end else begin
      FShownCustomDialogs.Add(Component);
      with TAndroidWidget(Component) do
      begin
        Left := 5;
        Width := TAndroidForm(Owner).Width - 10;
        jVisualControl(Component).LayoutParamWidth:= lpMatchParent; //jmpessoa
        maxH := 100;
        for i := 0 to ChildCount - 1 do
          with Children[i] do
            if maxH < Top + Height + MarginBottom then
              maxH := Top + Height + MarginBottom;
        Height := maxH;
        Top := (TAndroidForm(Owner).Height - maxH) div 2;
        if Top < 0 then Top := 0;
      end;
    end;
  end;
end;

{ TImageListPropertyEditor }

procedure TImageListPropertyEditor.GetValues(Proc: TGetStrProc);

  procedure TraverseComponents(Root: TComponent);
  var
    i: Integer;
  begin
    for i := 0 to Root.ComponentCount - 1 do
      if Root.Components[i] is jImageList then // in general "is GetTypeData(GetPropType)^.ClassType"
        Proc(Root.Components[i].Name);
  end;

begin
  Proc(oisNone);
  if Assigned(PropertyHook) and (PropertyHook.LookupRoot is TComponent) then
    TraverseComponents(TComponent(PropertyHook.LookupRoot));
end;

{ TImageIndexPropertyEditor }

function TImageIndexPropertyEditor.GetImageList: jImageList;
var
  Persistent: TPersistent;
  Component: jVisualControl;
  PropInfo: PPropInfo;
  Obj: TObject;
begin
  Result := nil;
  Persistent := GetComponent(0);
  if not (Persistent is jControl) then
    Exit;

  Component := jVisualControl(Persistent);
  PropInfo := TypInfo.GetPropInfo(Component, 'Images');
  if PropInfo = nil then
    Exit;

  Obj := GetObjectProp(Component, PropInfo);
  if Obj is jImageList then
    Exit(jImageList(Obj));
end;

procedure TImageIndexPropertyEditor.GetAssets;
var
  o: TPersistent;
  d: TAndroidWidgetMediator;
  pr: TLazProjectFile;
begin
  o := GetComponent(0);
  if not (o is TComponent) then
    Exit;
  o := TComponent(o).Owner;
  if not (o is TAndroidForm) then
    Exit;
  d := TAndroidForm(o).Designer as TAndroidWidgetMediator;
  pr := LazarusIDE.GetProjectFileWithRootComponent(TComponent(o));
  if pr = nil then
    Exit;
  if not (pr.GetFileOwner is TLazProject) then
    Exit;
  FAssetsPath := ExtractFilePath(TLazProject(pr.GetFileOwner).MainFile.GetFullFilename);
  FAssetsPath := System.Copy(FAssetsPath, 1, RPosEx(PathDelim, FAssetsPath, Length(FAssetsPath) - 1)) + 'assets' + PathDelim;
  FImageCache := d.ImageCache;
end;

procedure TImageIndexPropertyEditor.Activate;
begin
  inherited Activate;
  GetAssets;
  FImages := GetImageList;
end;

function TImageIndexPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paCustomDrawn, paRevertable];
end;

procedure TImageIndexPropertyEditor.GetValues(Proc: TGetStrProc);
var
  i: Integer;
begin
  if GetDefaultOrdValue <> NoDefaultValue then
    Proc(IntToStr(GetDefaultOrdValue));
  if Assigned(FImages) then
    for i := 0 to FImages.Count - 1 do
      Proc(IntToStr(i) + ' (' + FImages.Images[i] + ')');
end;

procedure TImageIndexPropertyEditor.SetValue(const NewValue: ansistring);
var
  Value: string;
  i: Integer;
begin
  Value := NewValue;
  i := Pos(' ', Value);
  if i > 0 then
    SetLength(Value, i - 1);
  inherited SetValue(Value);
end;

procedure TImageIndexPropertyEditor.ListDrawValue(const CurValue: ansistring;
  Index: integer; ACanvas: TCanvas; const ARect: TRect;
  AState: TPropEditDrawState);
var
  R: TRect;
  OldColor: TColor;
  bmp: TBitmap;
  x: Integer;
begin
  if GetDefaultOrdValue <> NoDefaultValue then
    Dec(Index);
  R := ARect;
  x := R.Bottom - R.Top - 2;
  if (pedsInComboList in AState) and not (pedsInEdit in AState) then
  begin
    OldColor := ACanvas.Brush.Color;
    if pedsSelected in AState then
      ACanvas.Brush.Color := clHighlight
    else
      ACanvas.Brush.Color := clWhite;
    ACanvas.FillRect(R);
    ACanvas.Brush.Color := OldColor;
  end;
  if Assigned(FImages) and Assigned(FImageCache)
  and (Index >= 0) and (Index < FImages.Images.Count) then
  begin
    bmp := FImageCache.GetImageAsBMP(FAssetsPath + FImages.Images[Index]);
    ACanvas.StretchDraw(Rect(R.Left+1, R.Top+1, R.Left+x+1, R.Top+x+1), bmp);
  end;
  R.Left := R.Left + x + 3;
  inherited ListDrawValue(CurValue, Index, ACanvas, R, AState);
end;

{ TjImageListEditor }

procedure TjImageListEditor.Edit;
var
  o: TComponent;
  d: TAndroidWidgetMediator;
  fn: string;
  TheDialog: TjImagesEditorDlg;
begin
  try
    o := TComponent(GetComponent).Owner;
    if not (o is TAndroidForm) then
      raise Exception.CreateFmt('%s owner is not TAndroidForm', [TComponent(GetComponent).Name]);
    d := TAndroidForm(o).Designer as TAndroidWidgetMediator;
    fn := d.AssetsDir;
    TheDialog := TjImagesEditorDlg.Create(Application, jImageList(GetComponent).Images,
      fn, d.ImageCache);
    try
      if TheDialog.ShowModal = mrOK then
      begin
        jImageList(GetComponent).Images.Assign(TheDialog.ImageList);
        Modified;
      end;
    finally
      TheDialog.Free;
    end;
  except
    on e: Exception do
      MessageDlg(e.Message, mtError, [mbOK], 0)
  end;
end;

procedure TjImageListEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;

function TjImageListEditor.GetVerb(Index: Integer): string;
begin
  Result := 'jImages Editor...';
end;

function TjImageListEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TjImageListImagesEditor }

procedure TjImageListImagesEditor.Edit;
var
  o: TComponent;
  d: TAndroidWidgetMediator;
  pr: TLazProjectFile;
  fn: string;
  TheDialog: TjImagesEditorDlg;
begin
  try
    o := TComponent(GetComponent(0)).Owner;
    if not (o is TAndroidForm) then
      raise Exception.CreateFmt('%s owner is not TAndroidForm', [TComponent(GetComponent(0)).Name]);
    d := TAndroidForm(o).Designer as TAndroidWidgetMediator;
    pr := LazarusIDE.GetProjectFileWithRootComponent(o);
    if pr = nil then
      raise Exception.CreateFmt('Project file for %s is not available!', [o.Name]);
    if not (pr.GetFileOwner is TLazProject) then
      raise Exception.Create('!!! ' + pr.GetFileOwner.ClassName);
    fn := ExtractFilePath(TLazProject(pr.GetFileOwner).MainFile.GetFullFilename);
    fn := Copy(fn, 1, RPosEx(PathDelim, fn, Length(fn) - 1)) + 'assets' + PathDelim;
    TheDialog := TjImagesEditorDlg.Create(Application, TStrings(GetObjectValue),
      fn, d.ImageCache);
    try
      if TheDialog.ShowModal = mrOK then
        SetPtrValue(TheDialog.ImageList);
    finally
      TheDialog.Free;
    end;
  except
    on e: Exception do
      MessageDlg(e.Message, mtError, [mbOK], 0)
  end;
end;

function TjImageListImagesEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

{ TAndroidFormSizePropertyEditor }

procedure TAndroidFormSizePropertyEditor.Edit;
begin
  with TAndroidFormSizeComponentEditor.Create(GetComponent(0) as TComponent, nil) do
  try
    ShowSelectSizeDialog
  finally
    Free
  end;
end;

function TAndroidFormSizePropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

{ TAndroidFormSizeComponentEditor }

procedure TAndroidFormSizeComponentEditor.ChangeSize(AWidth, AHeight: Integer);
begin
  with jForm(Component) do
  begin
    if Assigned(Designer) then
      with Designer as TAndroidWidgetMediator, LCLForm do
        SetBounds(Left, Top, AWidth, AHeight);
    SetBounds(Left, Top, AWidth, AHeight);
  end;
end;

procedure TAndroidFormSizeComponentEditor.ShowSelectSizeDialog;
begin
  with TfrmFormSizeSelect.Create(nil) do
  try
    with jForm(Component) do
      SetInitSize(Width, Height);
    if ShowModal = mrOk then
      ChangeSize(seWidth.Value, seHeight.Value);
  finally
    Free
  end;
end;

procedure TAndroidFormSizeComponentEditor.ExecuteVerb(Index: Integer);
var
  pr: TLazProjectFile;
begin
  case Index of
  0: // Rotate
    with jForm(Component) do
      ChangeSize(Height, Width);
  1: ShowSelectSizeDialog; // Select size
  2: begin
       pr := LazarusIDE.GetProjectFileWithRootComponent(Component);
       if pr <> nil then
         if not SameText(pr.CustomData['DisableLayout'], 'True') then
           pr.CustomData['DisableLayout'] := 'True'
         else
           pr.CustomData['DisableLayout'] := 'False';
     end;
  else
    inherited ExecuteVerb(Index);
  end;
end;

function TAndroidFormSizeComponentEditor.GetVerb(Index: Integer): string;
var
  pr: TLazProjectFile;
begin
  case Index of
  0: Result := 'Rotate';
  1: Result := 'Select size...';
  2: begin
       pr := LazarusIDE.GetProjectFileWithRootComponent(Component);
       if pr = nil then
         Result := '[--------------]'
       else
       if not SameText(pr.CustomData['DisableLayout'], 'True') then
         Result := 'Disable design-time layout'
       else
         Result := 'Enable design-time layout';
     end;
  else
    Result := inherited;
  end
end;

function TAndroidFormSizeComponentEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

{ TAnchorPropertyEditor }

procedure TAnchorPropertyEditor.GetValues(Proc: TGetStrProc);
var
  i, j: Integer;
  p: TAndroidWidget;
  sl: TStringList;
begin
  Proc(oisNone);
  p := jVisualControl(GetComponent(0)).Parent;
  for i := 1 to PropCount - 1 do
    if jVisualControl(GetComponent(i)).Parent <> p then
      Exit;
  sl := TStringList.Create;
  try
    for i := 0 to p.ChildCount - 1 do

    //if not (p is jCustomDialog) then   //commented by jmpessoa
      if not (p.Children[i] is jCustomDialog) then   //fixed by jmpessoa
        sl.Add(p.Children[i].Name);

    sl.Sorted := True;
    for i := 0 to PropCount - 1 do
    begin
      j := sl.IndexOf(TComponent(GetComponent(i)).Name);
      if j >= 0 then sl.Delete(j);
    end;
    for i := 0 to sl.Count - 1 do
      Proc(sl[i]);
  finally
    sl.Free;
  end;
end;

{ TDraftPanel }

procedure TDraftPanel.Draw;
begin
  with Fcanvas do
  begin
    if jPanel(FAndroidWidget).BackgroundColor <> colbrDefault then
      Brush.Color := ToTColor(jPanel(FAndroidWidget).BackgroundColor)
    else begin
      Brush.Color:= clNone;
      Brush.Style:= bsClear;
    end;
    Rectangle(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);    // outer frame
  end;
end;

{ TDraftControlHash }

function TDraftControlHash.Hash1(c: TClass): PtrUInt;
begin
  Result := ({%H-}PtrUInt(c) + {%H-}PtrUInt(c) shr 7) mod PtrUInt(Length(FItems));
end;

function TDraftControlHash.Hash2(i: PtrUInt): PtrUInt;
begin
  Result := (i + 7) mod PtrUInt(Length(FItems));
end;

constructor TDraftControlHash.Create(MaxCapacity: Integer);
begin
  SetLength(FItems, MaxCapacity);
  FFreeLeft := MaxCapacity;
end;

procedure TDraftControlHash.Add(VisualControlClass: jVisualControlClass;
  DraftWidgetClass: TDraftWidgetClass);
var
  i: PtrUInt;
begin
  if FFreeLeft = 0 then
    raise Exception.Create('[DraftControlHash] Overfull!');
  i := Hash1(VisualControlClass);
  while FItems[i].VisualControl <> nil do
    i := Hash2(i);
  with FItems[i] do
  begin
    VisualControl := VisualControlClass;
    Draft := DraftWidgetClass;
  end;
  Dec(FFreeLeft);
end;

function TDraftControlHash.Find(VisualControlClass: TClass): TDraftWidgetClass;
var i: PtrUInt;
begin
  Result := nil;
  i := Hash1(VisualControlClass);
  if FItems[i].VisualControl = nil then Exit;
  while FItems[i].VisualControl <> VisualControlClass do
  begin
    i := Hash2(i);
    if FItems[i].VisualControl = nil then Exit;
  end;
  Result := FItems[i].Draft;
end;

{ TARGBColorBridgePropertyEditor }

procedure TARGBColorBridgePropertyEditor.Edit;
var
  r1, g1, b1, r2, g2, b2: Byte;
  i, nearest: TARGBColorBridge;
  d, diff: Integer;
begin
  with TColorDialog.Create(nil) do
  try
    Color := ToTColor(TARGBColorBridge(GetOrdValue));
    if Execute then
    begin
      RedGreenBlue(Color, r1, g1, b1);
      i := Low(TARGBColorBridge);
      RedGreenBlue(ToTColor(i), r2, g2, b2);
      diff := Sqr(r1 - r2) + Sqr(g1 - g2) + Sqr(b1 - b2);
      nearest := i;
      if diff > 0 then
        for i := Succ(i) to High(TARGBColorBridge) do
        begin
          RedGreenBlue(ToTColor(i), r2, g2, b2);
          d := Sqr(r1 - r2) + Sqr(g1 - g2) + Sqr(b1 - b2);
          if diff > d then
          begin
            diff := d;
            nearest := i;
            if diff = 0 then Break;
          end;
        end;
      SetOrdValue(Ord(nearest));
    end;
  finally
    Free;
  end;
end;

function TARGBColorBridgePropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect,paValueList,paCustomDrawn,paDialog];
end;

procedure TARGBColorBridgePropertyEditor.ListDrawValue(const CurValue: ansistring;
  Index: integer; ACanvas: TCanvas; const ARect: TRect;
  AState: TPropEditDrawState);
var
  h: Integer;
  r: TRect;
  bc: TColor;
begin
  h := ARect.Bottom - ARect.Top;
  with ACanvas do
  begin
    FillRect(ARect);
    bc := Pen.Color;
    Pen.Color := clBlack;
    r := ARect;
    r.Right := r.Left + h;
    InflateRect(r, -2, -2);
    Rectangle(r);
    if (TARGBColorBridge(Index) in [colbrDefault, colbrCustom]) then
    begin
      InflateRect(r, -1, -1);
      MoveTo(r.Left, r.Top); LineTo(r.Right, r.Bottom);
      MoveTo(r.Right - 1, r.Top); LineTo(r.Left - 1, r.Bottom);
      Pen.Color := bc;
    end else begin
      Pen.Color := bc;
      bc := Brush.Color;
      Brush.Color := ToTColor(TARGBColorBridge(Index));
      InflateRect(r, -1, -1);
      FillRect(r);
      Brush.Color := bc;
    end;
  end;
  r := ARect;
  r.Left := r.Left + h + 2;
  inherited ListDrawValue(CurValue, Index, ACanvas, r, AState);
end;

procedure TARGBColorBridgePropertyEditor.PropDrawValue(ACanvas: TCanvas;
  const ARect: TRect; AState: TPropEditDrawState);
var
  s: string;
  i: Integer;
begin
  s := GetVisualValue;
  for i := 0 to Ord(High(TARGBColorBridge)) do
    if GetEnumName(TypeInfo(TARGBColorBridge), i) = s then
    begin
      ListDrawValue(s, i, ACanvas, ARect, [pedsInEdit]);
      Exit;
    end;
end;

{ TAndroidWidgetMediator }

constructor TAndroidWidgetMediator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDefaultBrushColor := clWhite;
  FDefaultPenColor := clMedGray;
  FDefaultFontColor := clMedGray;

  GlobalDesignHook.AddHandlerModified(@OnDesignerModified);
  GlobalDesignHook.AddHandlerPersistentAdded(@OnPersistentAdded);
  GlobalDesignHook.AddHandlerPersistentDeleted(@OnPersistentDeleted);
  GlobalDesignHook.AddHandlerPersistentDeleting(@OnPersistentDeleting);
  GlobalDesignHook.AddHandlerSetSelection(@OnSetSelection);

  FStarted := TFPList.Create;
  FDone := TFPList.Create;
  FCustomDialogs := TFPList.Create;
  FShownCustomDialogs := TFPList.Create;
  FSelection := TFPList.Create;

  FImageCache := TImageCache.Create;
end;

destructor TAndroidWidgetMediator.Destroy;
begin
  if Assigned(AndroidForm) then
    AndroidForm.Designer := nil;

  FImageCache.Free;
  FStarted.Free;
  FDone.Free;
  FSelection.Free;
  FCustomDialogs.Free;
  FShownCustomDialogs.Free;

  if GlobalDesignHook <> nil then
    GlobalDesignHook.RemoveAllHandlersForObject(Self);
  if LazarusIDE <> nil then
    LazarusIDE.RemoveAllHandlersOfObject(Self);

  inherited Destroy;
end;

//procedure TAndroidWidgetMediator.OnDesignerModified(Sender: TObject);
procedure TAndroidWidgetMediator.OnDesignerModified(Sender: TObject{$If lcl_fullversion=1070000}; {%H-}PropName: ShortString{$ENDIF});
var
  Instance: TPersistent;
  InvalidateNeeded: Boolean;
  i: Integer;
begin
  if not (Sender is TPropertyEditor) or (LCLForm = nil) then Exit;
  InvalidateNeeded := False;
  for i := 0 to TPropertyEditor(Sender).PropCount - 1 do
  begin
    Instance := TPropertyEditor(Sender).GetComponent(i);
    if (Instance = AndroidForm)
    and (AndroidForm.ActivityMode in [actMain, actSplash])
    and FProjFile.IsPartOfProject then
      LamwSmartDesigner.UpdateProjectStartModule(AndroidForm.Name);
    if (Instance = AndroidForm) or (Instance is jVisualControl)
    and (jVisualControl(Instance).Owner = AndroidForm) then
    begin
      InvalidateNeeded := True;
      Break;
    end;
  end;
  if InvalidateNeeded then
    LCLForm.Invalidate;
end;

procedure TAndroidWidgetMediator.OnPersistentAdded(APersistent: TPersistent; {%H-}Select: boolean);
begin
  if (APersistent is jVisualControl)
  and (jVisualControl(APersistent).Parent = nil)
  and (jVisualControl(APersistent).Owner = AndroidForm)
  then
    if Assigned(FLastSelectedContainer) then
      jVisualControl(APersistent).Parent := FLastSelectedContainer
    else
      jVisualControl(APersistent).Parent := AndroidForm;

  //smart designer helpers

  if (APersistent is jControl)
  and (jControl(APersistent).Owner = AndroidForm) then
    UpdateJControlsList;
end;

procedure TAndroidWidgetMediator.OnSetSelection(const ASelection: TPersistentSelectionList);
var
  i: Integer;
begin
  FLastSelectedContainer := nil;
  if (ASelection.Count = 1) and (ASelection[0] is jVisualControl) then
    with jVisualControl(ASelection[0]) do
      if (Owner = AndroidForm) and AcceptChildrenAtDesignTime then
        FLastSelectedContainer := jVisualControl(ASelection[0]);

  FSelection.Clear;
  for i := 0 to ASelection.Count - 1 do
    FSelection.Add(ASelection[i]);
end;

procedure TAndroidWidgetMediator.OnAutoAssignIDs(Sender: TObject);
begin
  if (Sender is TAndroidForm) and TAndroidForm(Sender).AutoAssignIDs then
    if QuestionDlg('LAMW', 'Reassign Id properties now (otherwise they will be reassigned on next form open)?', mtConfirmation, [mrYes, mrNo], 0) = mrYes then
      TAndroidForm(Sender).ReassignIds;
end;

procedure TAndroidWidgetMediator.SetRoot(const AValue: TComponent);
begin
  inherited SetRoot(AValue);
  if AValue is jForm then
    jForm(AValue).OnAutoAssignIDs := @OnAutoAssignIDs;
end;

function TAndroidWidgetMediator.GetAndroidForm: jForm;
begin
  Result := jForm(Root);
end;

procedure TAndroidWidgetMediator.InitSmartDesignerHelpers;
begin
  if (FProjFile<>nil)
  and FProjFile.IsPartOfProject
  and not FProjFile.CustomData.Contains('jControls') then
    UpdateJControlsList;
end;

procedure TAndroidWidgetMediator.OnPersistentDeleting(APersistent: TPersistent);
begin
  FjControlDeleted := (APersistent is jControl)
    and (Root <> nil) and (TComponent(APersistent).Owner = Root);
  if FjControlDeleted then
    FShownCustomDialogs.Remove(APersistent);
end;

procedure TAndroidWidgetMediator.UpdateJControlsList;
begin
  LamwSmartDesigner.UpdateJContros(FProjFile, AndroidForm);
end;

class function TAndroidWidgetMediator.CreateMediator(TheOwner, TheForm: TComponent): TDesignerMediator;
var
  Mediator: TAndroidWidgetMediator;
  i: Integer;
begin
  Result := inherited CreateMediator(TheOwner, nil);

  Mediator := TAndroidWidgetMediator(Result);
  Mediator.Root := TheForm;
  Mediator.AndroidForm.Designer := Mediator;

  Mediator.UpdateTheme;
  Mediator.FProjFile := LazarusIDE.GetProjectFileWithRootComponent(TheForm);
  Mediator.InitSmartDesignerHelpers;

  for i := 0 to TheForm.ComponentCount - 1 do
    if TheForm.Components[i] is jCustomDialog then
      with jCustomDialog(TheForm.Components[i]) do
        DesignInfo := LeftTopToDesignInfo(Left, Top);

end;

class function TAndroidWidgetMediator.FormClass: TComponentClass;
begin
  Result := TAndroidForm;
end;

procedure TAndroidWidgetMediator.GetBounds(AComponent: TComponent; out CurBounds: TRect);
var
  w: TAndroidWidget;
begin
  if AComponent is TAndroidWidget then
  begin
    w := TAndroidWidget(AComponent);
    if ComponentIsIcon(AComponent) then
      CurBounds := Bounds(LeftFromDesignInfo(w.DesignInfo),
                          TopFromDesignInfo(w.DesignInfo), 28, 28)
    else
      CurBounds := Bounds(w.Left, w.Top, w.Width, w.Height);
  end else inherited GetBounds(AComponent,CurBounds);
end;

procedure TAndroidWidgetMediator.OnPersistentDeleted;
begin
  if FjControlDeleted then
    UpdateJControlsList;
end;

procedure TAndroidWidgetMediator.InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
begin
  if (LCLForm=nil) or (not LCLForm.HandleAllocated) then exit;
  LCLIntf.InvalidateRect(LCLForm.Handle,@ARect,Erase);
end;

function TAndroidWidgetMediator.AssetsDir: string;
begin
  if FProjFile = nil then
    raise Exception.CreateFmt('Project file for %s is not available!', [Root.Name]);
  Result := ExtractFilePath(TLazProject(FProjFile.GetFileOwner).MainFile.GetFullFilename);
  Result := Copy(Result, 1, RPosEx(PathDelim, Result, Length(Result) - 1)) + 'assets' + PathDelim;
end;

procedure TAndroidWidgetMediator.GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer);
begin
  if (APersistent is TAndroidWidget) and (TAndroidWidget(APersistent).AcceptChildrenAtDesignTime) then
    AIndex:= FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexBox
  else if (APersistent is TAndroidWidget) then
    AIndex:= FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexControl
  else
    inherited GetObjInspNodeImageIndex(APersistent, AIndex);
end;

procedure TAndroidWidgetMediator.SetBounds(AComponent: TComponent; NewBounds: TRect);
begin
  if AComponent is TAndroidWidget then
  begin
    TAndroidWidget(AComponent).SetBounds(NewBounds.Left,NewBounds.Top,
      NewBounds.Right-NewBounds.Left,NewBounds.Bottom-NewBounds.Top);
    if ComponentIsIcon(AComponent) then
      with TAndroidWidget(AComponent) do
        DesignInfo := LeftTopToDesignInfo(NewBounds.Left, NewBounds.Top);
  end else inherited SetBounds(AComponent,NewBounds);
end;

procedure TAndroidWidgetMediator.GetClientArea(AComponent: TComponent; out
  CurClientArea: TRect; out ScrollOffset: TPoint);
var
  Widget: TAndroidWidget;
begin
  if (AComponent is TAndroidWidget) and not ComponentIsIcon(AComponent) then
  begin
    Widget:=TAndroidWidget(AComponent);
    CurClientArea:=Rect(0, 0, Widget.Width, Widget.Height);
    ScrollOffset:=Point(0, 0);
  end
  else inherited GetClientArea(AComponent, CurClientArea, ScrollOffset);
end;

procedure TAndroidWidgetMediator.InitComponent(AComponent, NewParent: TComponent; NewBounds: TRect);
begin
  if AComponent <> AndroidForm then // to preserve jForm size
  begin
    if AComponent is TAndroidWidget then
    begin
      with NewBounds do
        if (Right - Left = 50) and (Bottom - Top = 50) then // ugly check, but IDE makes 50x50 default size for non TControl
        begin
          // restore default size
          Right := Left + TAndroidWidget(AComponent).Width;
          Bottom := Top + TAndroidWidget(AComponent).Height
        end;
    end;
    inherited InitComponent(AComponent, NewParent, NewBounds);
    if (AComponent is jVisualControl)
    and Assigned(jVisualControl(AComponent).Parent) then
      with jVisualControl(AComponent) do
      begin
        if not (LayoutParamWidth in [lpWrapContent, lpExact, lpUseWeight]) then
          LayoutParamWidth := GetDesignerLayoutByWH(Width, Parent.Width);
        if not (LayoutParamHeight in [lpWrapContent, lpExact, lpUseWeight]) then
          LayoutParamHeight := GetDesignerLayoutByWH(Height, Parent.Height);
      end;
  end;
end;

procedure TAndroidWidgetMediator.Paint;
var
  CanUpdateLayout: Boolean;

  procedure PaintWidget(AWidget: TAndroidWidget);
  var
    i: Integer;
    Child: TAndroidWidget;
    fpcolor: TFPColor;
    fWidget: TDraftWidget;
    fWidgetClass: TDraftWidgetClass;
  begin

    if FDone.IndexOf(AWidget) >= 0 then Exit;
    if FStarted.IndexOf(AWidget) >= 0 then
    begin
      jVisualControl(AWidget).Anchor := nil;
      MessageBox(0, 'Circular dependency detected!', '[Lamw] Designer', MB_ICONERROR);
      Abort;
    end;
    FStarted.Add(AWidget);

    with LCLForm.Canvas do begin
      //fill background

      Brush.Style:= bsSolid;
      Brush.Color:= Self.FDefaultBrushColor;
      Pen.Color:= Self.FDefaultPenColor;      //MedGray...
      Font.Color:= Self.FDefaultFontColor;

      if AWidget is jVisualControl then
        with jVisualControl(AWidget) do
          if Assigned(Anchor) then
          begin
            RestoreHandleState;
            SaveHandleState;
            MoveWindowOrgEx(Handle, Anchor.Left, Anchor.Top);
            IntersectClipRect(Handle, 0, 0, Anchor.Width, Anchor.Height);
            PaintWidget(Anchor); // needed for update its layout
            RestoreHandleState;
            SaveHandleState;
            MoveWindowOrgEx(Handle, AWidget.Left, AWidget.Top);
          end;

      if (AWidget is jForm) then
      begin
        if jForm(AWidget).BackgroundColor <> colbrDefault then
        begin
          fpcolor:= ToTFPColor(jForm(AWidget).BackgroundColor);
          Brush.Color:= FPColorToTColor(fpcolor);
          Rectangle(0,0,AWidget.Width,AWidget.Height); // outer frame
        end
        else
        begin
          Brush.Color := FDefaultBrushColor;
          GradientFill(Rect(0,0,AWidget.Width,AWidget.Height),
            BlendColors(FDefaultBrushColor, 0.92, 0, 0, 0),
            BlendColors(FDefaultBrushColor, 0.81, 255, 255, 255),
            gdVertical);
        end;
      end else
      // generic
      begin
        fWidgetClass := DraftClassesMap.Find(AWidget.ClassType);
        if Assigned(fWidgetClass) then
        begin
          fWidget := fWidgetClass.Create(AWidget, LCLForm.Canvas);
          if CanUpdateLayout
          and (not FSizing or (FSelection.IndexOf(AWidget) < 0)) then
            fWidget.UpdateLayout;
          fWidget.Draw;
          fWidget.Free;
        end
        //// default drawing: rect with Text
        else if (AWidget is jVisualControl) then
        begin
          Brush.Color:= Self.FDefaultBrushColor;
          FillRect(0,0,AWidget.Width,AWidget.Height);
          Rectangle(0,0,AWidget.Width,AWidget.Height);    // outer frame
          //generic
          Font.Color:= clMedGray;
          TextOut(5,4,AWidget.Text);
        end;
      end;

      if AWidget.AcceptChildrenAtDesignTime then
      begin       //inner rect...
        if not (AWidget is jForm) then
        begin
          Pen.Color:= clSilver;
          Frame(2, 2, AWidget.Width - 2, AWidget.Height - 2); // inner frame
        end;
      end;

      // children
      if AWidget.ChildCount>0 then
      begin
        SaveHandleState;
        // clip client area
        if IntersectClipRect(Handle, 0, 0, AWidget.Width, AWidget.Height)<>NullRegion then
        begin
          for i:=0 to AWidget.ChildCount-1 do
          begin
            Child:=AWidget.Children[i];
            if Child is jCustomDialog then
            begin
              if not ComponentIsIcon(Child) then
                FCustomDialogs.Add(Child);
              Continue;
            end;
            SaveHandleState;
            // clip child area
            MoveWindowOrgEx(Handle,Child.Left,Child.Top);
            if IntersectClipRect(Handle,0,0,Child.Width,Child.Height)<>NullRegion then
               PaintWidget(Child);
            RestoreHandleState;
          end;
        end;
        RestoreHandleState;
      end;
    end;
    FStarted.Remove(AWidget);
    FDone.Add(AWidget);
  end;

  procedure PaintCustomDialog(cd: jCustomDialog);
  var
     i: Integer;
    Child: TAndroidWidget;
  begin
    with LCLForm.Canvas do begin
      SaveHandleState;
      if cd.BackgroundColor <> colbrDefault then
        Brush.Color:= FPColorToTColor(ToTFPColor(cd.BackgroundColor))
      else
        Brush.Color:= FDefaultBrushColor;
      MoveWindowOrgEx(Handle,cd.Left,cd.Top);
      IntersectClipRect(Handle, 0, 0, cd.Width, cd.Height);
      Brush.Style := bsSolid;
      Rectangle(0, 0, cd.Width, cd.Height);    // outer frame
      Brush.Style := bsClear;
      Font.Color := clMedGray;
      TextOut(6, 4, cd.Text);
      Pen.Color:= clSilver; //clWhite;
      Frame(4, 4, cd.Width-4, cd.Height-4); // inner frame

      // children
      if cd.ChildCount > 0 then
        for i := 0 to cd.ChildCount - 1 do
        begin
          SaveHandleState;
          Child := cd.Children[i];
          // clip child area
          MoveWindowOrgEx(Handle, Child.Left, Child.Top);
          if IntersectClipRect(Handle, 0, 0, Child.Width, Child.Height) <> NullRegion then
            PaintWidget(Child);
          RestoreHandleState;
        end;
      RestoreHandleState;
    end;
  end;

var
  i: Integer;
begin
  CanUpdateLayout := (FProjFile = nil)
    or not SameText(FProjFile.CustomData['DisableLayout'], 'True');
  FStarted.Clear;
  FDone.Clear;
  FCustomDialogs.Clear; // jCustomDialogs are drawn after all other components
  PaintWidget(AndroidForm);
  for i := 0 to FCustomDialogs.Count - 1 do
    PaintCustomDialog(jCustomDialog(FCustomDialogs[i]));

  inherited Paint;
end;

function TAndroidWidgetMediator.ComponentIsIcon(AComponent: TComponent): boolean;
begin
  Result := not (AComponent is TAndroidWidget)
    or (AComponent is jCustomDialog)
       and (FShownCustomDialogs.IndexOf(AComponent) < 0);
end;

function TAndroidWidgetMediator.ComponentIsVisible(AComponent: TComponent): Boolean;
begin
  Result := inherited ComponentIsVisible(AComponent);
  while Result and (AComponent is jVisualControl) do
  begin
    AComponent := jVisualControl(AComponent).Parent;
    if AComponent is jCustomDialog then
      Result := not ComponentIsIcon(AComponent)
  end;
end;

function TAndroidWidgetMediator.ParentAcceptsChild(Parent: TComponent; Child: TComponentClass): boolean;
begin
  Result:=(Parent is TAndroidWidget) and
          (Child.InheritsFrom(TAndroidWidget)) and
          (TAndroidWidget(Parent).AcceptChildrenAtDesignTime);
end;

procedure TAndroidWidgetMediator.UpdateTheme;
var
  proj: TLazProjectFile;
  fn: string;
begin
  try
    proj := LazarusIDE.GetProjectFileWithRootComponent(Root);

    if proj <> nil then
    begin
      if proj.IsPartOfProject then
        fn := LazarusIDE.ActiveProject.MainFile.GetFullFilename
      else
        fn := proj.GetFullFilename;
      if (Pos(PathDelim + 'jni' + PathDelim, fn) = 0)
      and (proj.GetFileOwner is TLazProject) then
      begin // main file is not saved yet => get path of first module
        proj := TLazProject(proj.GetFileOwner).Files[1];
        fn := proj.GetFullFilename;
      end;
      fn := Copy(fn, 1, Pos(PathDelim + 'jni' + PathDelim, fn));
      fn := fn + 'AndroidManifest.xml';
      FTheme := Themes.GetTheme(fn);
      if FTheme <> nil then
      begin
        FDefaultBrushColor := FTheme.GetColorDef('colorBackground', clWhite);
        FDefaultFontColor := FTheme.GetColorDef('textColorPrimary', clBlack);
        if Assigned(LCLForm) then LCLForm.Invalidate;
      end;
    end;
  except
    on e: Exception do
      IDEMessagesWindow.AddCustomMessage(mluError, e.Message);
  end;
end;

procedure TAndroidWidgetMediator.MouseDown(Button: TMouseButton;
  Shift: TShiftState; p: TPoint; var Handled: boolean);
begin
  inherited MouseDown(Button, Shift, p, Handled);
end;

procedure TAndroidWidgetMediator.MouseUp(Button: TMouseButton;
  Shift: TShiftState; p: TPoint; var Handled: boolean);
begin
  inherited MouseUp(Button, Shift, p, Handled);
  FSizing := False;
  LCLForm.Invalidate;
end;

procedure TAndroidWidgetMediator.MouseMove(Shift: TShiftState; p: TPoint;
  var Handled: boolean);
begin
  if ssLeft in Shift then FSizing := True;
  inherited MouseMove(Shift, p, Handled);
end;

{ TDraftWidget }

constructor TDraftWidget.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
var
  x: TLayoutParams;
  y, z, FnewW, FnewH: Integer;
begin
  TextColor:= clNone;
  BackGroundColor:= clNone;
  FAndroidWidget := AWidget;
  FCanvas := Canvas;
  FColor := colbrDefault;

  with jVisualControl(FAndroidWidget) do
  begin
    FLeftTop := Point(-1, -1);
    FRightBottom := Point(-1, -1);
    FMinWidth := 0;
    FMinHeight := 0;
    with Designer do
      if FSizing and (FSelection.IndexOf(AWidget) >= 0)
      and (Parent <> nil) then
      begin
        if not (LayoutParamWidth in [lpWrapContent, lpExact, lpUseWeight]) then
        begin
          FnewW := Width;
          x := GetDesignerLayoutByWH(FnewW, Parent.Width);
          y := GetLayoutParamsByParent2(Parent, x, sdW);
          if LayoutParamWidth = lpMatchParent then
            z := Parent.Width - MarginLeft - FLeftTop.x - MarginRight
          else
            z := GetLayoutParamsByParent2(Parent, LayoutParamWidth, sdW);
          if (z <> FnewW) and (Abs(y - FnewW) < Abs(z - FnewW)) then
            LayoutParamWidth := x;
        end;
        if not (LayoutParamHeight in [lpWrapContent, lpExact, lpUseWeight]) then
        begin
          FnewH := Height;
          x := GetDesignerLayoutByWH(FnewH, Parent.Height);
          y := GetLayoutParamsByParent2(Parent, x, sdH);
          if LayoutParamHeight = lpMatchParent then
            z := Parent.Height - MarginTop - FLeftTop.y - MarginBottom
          else
            z := GetLayoutParamsByParent2(Parent, LayoutParamHeight, sdH);
          if (z <> FnewH) and (Abs(y - FnewH) < Abs(z - FnewH)) then
            LayoutParamHeight := x;
        end;
      end;
  end;

  Height := AWidget.Height;
  Width := AWidget.Width;
  MarginLeft := AWidget.MarginLeft;
  MarginTop := AWidget.MarginTop;
  MarginRight := AWidget.MarginRight;
  MarginBottom := AWidget.MarginBottom;
end;


procedure TDraftWidget.Draw;
begin
  with FCanvas do
  begin
    if Color <> colbrDefault then
      Brush.Color := ToTColor(Color)
    else begin
      Brush.Color:= clNone;
      Brush.Style:= bsClear;
    end;
    Rectangle(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);    // outer frame
    TextOut(12, 9, FAndroidWidget.Text);
  end;
end;

procedure TDraftWidget.UpdateLayout;
var
  FnewW, FnewH: Integer;
begin
  with jVisualControl(FAndroidWidget) do
  begin
    lpWidth := LayoutParamWidth;
    lpHeight := LayoutParamHeight;
    if Assigned(Parent) then
    begin
      case lpWidth of
        lpMatchParent:
          if Assigned(Parent) then
          begin
            FLeftTop.x := MarginLeft;
            FRightBottom.x := Parent.Width - MarginRight;
          end;
        lpWrapContent:
          if ChildCount > 0 then
          begin
            FnewW := WrapContentWidthByChildren;
            if FMinWidth < FnewW then FMinWidth := FnewW;
          end;
        else begin
          FnewW := GetLayoutParamsByParent2(Parent, lpWidth, sdW);
          if FMinWidth < FnewW then FMinWidth := FnewW;
        end;
      end;
      case lpHeight of
        lpMatchParent:
          if Assigned(Parent) then
          begin
            FLeftTop.y := MarginTop;
            FRightBottom.y := Parent.Height - MarginBottom;
          end;
        lpWrapContent:
          if ChildCount > 0 then
          begin
            FnewH := WrapContentHeightByChildren;
            if FMinHeight < FnewH then FMinHeight := FnewH;
          end;
        else begin
          FnewH := GetLayoutParamsByParent2(Parent, lpHeight, sdH);
          if FMinHeight < FnewH then FMinHeight := FnewH;
        end;
      end;
      if (rpRight in PosRelativeToParent) and Assigned(Parent) then
        FRightBottom.x := Parent.Width - MarginRight;
      if rpLeft in PosRelativeToParent then
        FLeftTop.x := MarginLeft;
      if rpTop in PosRelativeToParent then
        FLeftTop.y := MarginTop;
      if (rpBottom in PosRelativeToParent) and Assigned(Parent) then
        FRightBottom.y := Parent.Height - MarginBottom;
      if rpCenterHorizontal in PosRelativeToParent then
        FLeftTop.x := (Parent.Width - GetNewWidth) div 2;
      if rpCenterVertical in PosRelativeToParent then
        FLeftTop.y := (Parent.Height - GetNewHeight) div 2;
      if rpCenterInParent in PosRelativeToParent then
      begin
        FLeftTop.x := (Parent.Width - GetNewWidth) div 2;
        FLeftTop.y := (Parent.Height - GetNewHeight) div 2;
      end;
      { TODO: rpStart, rpEnd }
    end;
    if Anchor <> nil then
    begin
      if raBelow in PosRelativeToAnchor then
        FLeftTop.y := Anchor.Top + Anchor.Height + Anchor.MarginBottom + MarginTop;
      if raAbove in PosRelativeToAnchor then
        FLeftTop.y := Anchor.Top - Height - MarginBottom - Anchor.MarginTop;
      if raToRightOf in PosRelativeToAnchor then
        FLeftTop.x := Anchor.Left + Anchor.Width + Anchor.MarginRight + MarginLeft;
      if raAlignBaseline in PosRelativeToAnchor then
        FLeftTop.y := Anchor.Top + (Anchor.Height - Height) div 2;
      if raAlignLeft in PosRelativeToAnchor then
        FLeftTop.x := Anchor.Left + MarginLeft;
      if raToEndOf in PosRelativeToAnchor then
        FLeftTop.x := Anchor.Left + Anchor.Width + Anchor.MarginRight + MarginLeft;
      if raAlignTop in PosRelativeToAnchor then
        FLeftTop.y := Anchor.Top + MarginTop;
      { TODO: other combinations }
      if ([raBelow, raAlignBottom] * PosRelativeToAnchor <> [])
      and Assigned(Parent) and (rpBottom in PosRelativeToParent) then
        FRightBottom.y := Parent.Height - MarginBottom;
    end;
  end;
  SetBounds;
end;

procedure TDraftWidget.SetColor(AColor: TARGBColorBridge);
begin
  FColor := AColor;
  if AColor <> colbrDefault then
    BackGroundColor := ToTColor(AColor)
  else
    BackGroundColor := clNone;
end;

procedure TDraftWidget.SetFontColor(AColor: TARGBColorBridge);
begin
  FFontColor := AColor;
  if AColor <> colbrDefault then
    TextColor := ToTColor(AColor)
  else
    TextColor := DefaultTextColor;
end;

function TDraftWidget.Designer: TAndroidWidgetMediator;
var
  t: TAndroidWidget;
begin
  Result := nil;
  if FAndroidWidget = nil then Exit;
  t := FAndroidWidget;
  while Assigned(t.Parent) do t := t.Parent;
  if t is TAndroidForm then
    Result := TAndroidForm(t).Designer as TAndroidWidgetMediator;
end;

function TDraftWidget.WrapContentWidthByChildren: Integer;
var
  i, t: Integer;
begin
  with jVisualControl(FAndroidWidget) do
  begin
    Result := 0;
    for i := 0 to ChildCount - 1 do
      with jVisualControl(Children[i]) do
      begin
        if LayoutParamWidth = lpMatchParent then
          lpWidth := lpMatchParent;
        t := Left + Width + MarginRight;
        if t > Result then Result := t;
      end;
  end;
end;

function TDraftWidget.WrapContentHeightByChildren: Integer;
var
  i, t: Integer;
begin
  with jVisualControl(FAndroidWidget) do
  begin
    Result := 0;
    for i := 0 to ChildCount - 1 do
      with jVisualControl(Children[i]) do
      begin
        if (LayoutParamHeight = lpMatchParent) then
          lpHeight := lpMatchParent;
        t := Top + Height + MarginBottom;
        if t > Result then Result := t;
      end;
  end;
end;

function TDraftWidget.GetParentBackgroundColor: TARGBColorBridge;
begin
  // TODO: Parent.AcceptChildrenAtDesignTime
  if FAndroidWidget.Parent is jPanel then
  begin
    Result := jPanel(FAndroidWidget.Parent).BackgroundColor;
  end else
  if FAndroidWidget.Parent is jCustomDialog then
  begin
    Result := jCustomDialog(FAndroidWidget.Parent).BackgroundColor;
  end else
    Result := Color;
end;

function TDraftWidget.GetBackGroundColor: TColor;
var
  w: TAndroidWidget;
  d: TDraftWidgetClass;
begin
  Result := BackGroundColor;
  if Result = clNone then
  begin
    w := FAndroidWidget.Parent;
    while (Result = clNone) and (w is jVisualControl) do
    begin
      d := DraftClassesMap.Find(w.ClassType);
      if d = nil then Break;
      with d.Create(w, FCanvas) do
      begin
        Result := BackGroundColor;
        w := w.Parent;
        Free;
      end;
    end;
    if (Result = clNone) and (w is jForm)
    and (jForm(w).BackgroundColor <> colbrDefault) then
      Result := ToTColor(jForm(w).BackgroundColor)
    else
      Result := Designer.FDefaultBrushColor;
  end;
end;

function TDraftWidget.DefaultTextColor: TColor;
var
  t: TAndroidTheme;
begin
  if BaseStyle <> '' then
  begin
    t := Designer.AndroidTheme;
    if t <> nil then
    begin
      if t.TryGetColor([BaseStyle, 'android:textColor'], Result) then Exit;
      if t.TryGetColor([BaseStyle,
                       'android:textAppearance',
                       'android:textColor'], Result) then Exit;
    end;
  end;
  Result := Designer.FDefaultFontColor;
end;

function TDraftWidget.GetNewWidth: Integer;
begin
  if (FLeftTop.x >= 0) and (FRightBottom.x >= 0) then
    Result := FRightBottom.x - FLeftTop.x
  else
  if FMinWidth > 0 then
    Result := FMinWidth
  else
    Result := Width;
  if Result < FMinWidth then
    Result := FMinWidth;
end;

function TDraftWidget.GetNewHeight: Integer;
begin
  if (FLeftTop.y >= 0) and (FRightBottom.y >= 0) then
    Result := FRightBottom.y - FLeftTop.y
  else
  if FMinHeight > 0 then
    Result := FMinHeight
  else
    Result := Height;
  if Result < FMinHeight then
    Result := FMinHeight;
end;

procedure TDraftWidget.SetBounds;
var
  newWidth, newHeight: Integer;
begin
  newWidth := GetNewWidth;
  newHeight := GetNewHeight;

  if FLeftTop.x < 0 then
    if FRightBottom.x >= 0 then
      FLeftTop.x := FRightBottom.x - newWidth
    else
      FLeftTop.x := jVisualControl(FAndroidWidget).Left;

  if FLeftTop.y < 0 then
    if FRightBottom.y >= 0 then
      FLeftTop.y := FRightBottom.y - newHeight
    else
      FLeftTop.y := jVisualControl(FAndroidWidget).Top;

  with jVisualControl(FAndroidWidget) do
    SetBounds(FLeftTop.x, FLeftTop.y, newWidth, newHeight);
end;

{ TDraftButton }

constructor TDraftButton.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  BaseStyle := 'buttonStyle';
  inherited;

  Color := jButton(AWidget).BackgroundColor;
  FontColor := jButton(AWidget).FontColor;

  if jButton(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftButton.Draw;
var
  r: TRect;
  ts: TTextStyle;
  lastFontSize: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := BackGroundColor;
    Pen.Color := clForm;
    Font.Color := TextColor;

    if BackGroundColor = clNone then
      Brush.Color := BlendColors(GetBackGroundColor, 2/5, 153, 153, 153);

    lastFontSize := Font.Size;
    Font.Size := AndroidToLCLFontSize(jButton(FAndroidWidget).FontSize, 13);

    r := Rect(0, 0, Self.Width, Self.Height);
    FillRect(r);
    //outer frame
    Rectangle(r);

    Pen.Color := clMedGray;
    Brush.Style := bsClear;
    InflateRect(r, -1, -1);
    Rectangle(r);

    ts := TextStyle;
    ts.Layout := tlCenter;
    ts.Alignment := Classes.taCenter;
    TextRect(r, r.Left, r.Top, FAndroidWidget.Text, ts);
    Font.Size := lastFontSize;
  end;
end;

procedure TDraftButton.UpdateLayout;
begin
  with jButton(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
    begin
      FMinHeight := 14 + AndroidToLCLFontSize(jButton(FAndroidWidget).FontSize, 13) + 13;
      if FMinHeight < 40 then FMinHeight := 40;
    end;
  inherited UpdateLayout;
end;

{ TDraftTextView }

constructor TDraftTextView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  BaseStyle := 'textViewStyle';
  inherited;
  Color := jTextView(AWidget).BackgroundColor;
  if Color = colbrDefault then
    Color := GetParentBackgroundColor;
  FontColor := jTextView(AWidget).FontColor;
end;

procedure TDraftTextView.Draw;
var
  lastSize, ps: Integer;
begin
  with Fcanvas do
  begin
    ps := AndroidToLCLFontSize(jTextView(FAndroidWidget).FontSize, 10);
    lastSize := Font.Size;
    Font.Size := ps;

    Brush.Color := BackGroundColor;
    Pen.Color := TextColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
    else
      Brush.Style := bsClear;

    Font.Color := TextColor;

    TextOut(0, (ps + 5) div 10, FAndroidWidget.Text);
    Font.Size := lastSize;
  end;
end;

procedure TDraftTextView.UpdateLayout;
var
  ps, lastSize: Integer;
begin
  with jTextView(FAndroidWidget), FCanvas do
    if (LayoutParamWidth = lpWrapContent)
    or (LayoutParamHeight = lpWrapContent) then
    begin
      lastSize := Font.Size;
      ps := AndroidToLCLFontSize(FontSize, 10);
      Font.Size := ps;
      with TextExtent(Text) do
      begin
        if LayoutParamWidth = lpWrapContent then
          FMinWidth := cx;
        if LayoutParamHeight = lpWrapContent then
          FMinHeight := cy + 2 + (ps + 5) div 10;
      end;
      Font.Size := lastSize;
    end;
  inherited UpdateLayout;
end;

{ TDraftEditText }

constructor TDraftEditText.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  BaseStyle := 'editTextStyle';
  inherited;
  Color := jEditText(AWidget).BackgroundColor;
  if Color = colbrDefault then
    Color := GetParentBackgroundColor;
  FontColor := jEditText(AWidget).FontColor;
end;

procedure TDraftEditText.Draw;
var
  ls: Integer;
begin
  with FCanvas do
  begin
    if BackgroundColor <> clNone then
    begin
      Brush.Color := BackGroundColor;
      FillRect(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);
    end else
      Brush.Style := bsClear;
    Font.Color := TextColor;
    ls := Font.Size;
    Font.Size := AndroidToLCLFontSize(jEditText(FAndroidWidget).FontSize, 13);
    TextOut(12, 9, jEditText(FAndroidWidget).Text);
    Font.Size := ls;
    if BackgroundColor = clNone then
    begin
      Pen.Color := RGBToColor(175,175,175);
      with FAndroidWidget do
      begin
        MoveTo(4, Height - 8);
        Lineto(4, Height - 5);
        Lineto(Width - 4, Height - 5);
        Lineto(Width - 4, Height - 8);
      end;
    end;
  end;
end;

procedure TDraftEditText.UpdateLayout;
var
  fs: Integer;
begin
  with jEditText(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
    begin
      fs := FontSize;
      if fs = 0 then fs := 18;
      FMinHeight := 29 + (fs - 10) * 4 div 3; // todo: multiline
    end;
  inherited;
end;

{TDraftAutoTextView}

constructor TDraftAutoTextView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  BaseStyle := 'autoTextViewStyle';
  inherited;
  Color := jAutoTextView(AWidget).BackgroundColor;
  FontColor := jAutoTextView(AWidget).FontColor;
end;

procedure TDraftAutoTextView.Draw;
var
  ls: Integer;
begin
  with FCanvas do
  begin
    if BackgroundColor <> clNone then
    begin
      Brush.Color := BackGroundColor;
      FillRect(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);
    end else
      Brush.Style := bsClear;
    Font.Color := TextColor;

    ls := Font.Size;
    Font.Size := AndroidToLCLFontSize(jAutoTextView(FAndroidWidget).FontSize, 13);
    TextOut(4, 12, jAutoTextView(FAndroidWidget).Text);
    Font.Size := ls;

    if BackgroundColor = clNone then
    begin
      Pen.Color := RGBToColor(175,175,175);
      with FAndroidWidget do
      begin
        MoveTo(4, Height - 8);
        Lineto(4, Height - 5);
        Lineto(Width - 4, Height - 5);
        Lineto(Width - 4, Height - 8);
      end;
    end;
  end;
end;

procedure TDraftAutoTextView.UpdateLayout;
var
  fs: Integer;
begin
  with jAutoTextView(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
    begin
      fs := FontSize;
      if fs = 0 then fs := 18;
      FMinHeight := 29 + (fs - 10) * 4 div 3; // todo: multiline
    end;
  inherited UpdateLayout;
end;

{ TDraftCheckBox }

constructor TDraftCheckBox.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  BaseStyle := 'checkboxStyle';
  inherited;
  Color := jCheckBox(AWidget).BackgroundColor;
  FontColor := jCheckBox(AWidget).FontColor;
end;

procedure TDraftCheckBox.Draw;
var
  lastSize, ps: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := Self.BackGroundColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
    else
      Brush.Style := bsClear;

    Font.Color := TextColor;

    lastSize := Font.Size;
    ps := AndroidToLCLFontSize(jCheckBox(FAndroidWidget).FontSize, 12);
    Font.Size := ps;
    TextOut(32, 14 - Abs(Font.Height) div 2, FAndroidWidget.Text);
    Font.Size := lastSize;

    Brush.Color := clWhite;
    Brush.Style := bsClear;
    Pen.Color := RGBToColor($A1,$A1,$A1);
    Rectangle(8, 8, 24, 24);
    if jCheckBox(FAndroidWidget).Checked then
    begin
      lastSize := Pen.Width;
      Pen.Width := 4;
      Pen.Color := RGBToColor($44,$B3,$DD);
      MoveTo(12, 13);
      LineTo(16, 18);
      LineTo(26, 7);
      Pen.Width := lastSize;
    end;
  end;
end;

procedure TDraftCheckBox.UpdateLayout;
var
  ls, ps: Integer;
begin
  with jCheckBox(FAndroidWidget) do
  begin
    if LayoutParamHeight = lpWrapContent then
      FMinHeight := 32;
    if LayoutParamWidth = lpWrapContent then
    begin
      ps := AndroidToLCLFontSize(FontSize, 12);
      ls := FCanvas.Font.Size;
      FCanvas.Font.Size := ps;
      FMinWidth := 33 + FCanvas.TextWidth(Text);
      FCanvas.Font.Size := ls;
    end;
  end;
  inherited UpdateLayout;
end;

{ TDraftRadioButton }

constructor TDraftRadioButton.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  BaseStyle := 'radioButtonStyle';
  inherited;
  Color := jRadioButton(AWidget).BackgroundColor;
  FontColor := jRadioButton(AWidget).FontColor;
end;

procedure TDraftRadioButton.Draw;
var
  lastSize: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := BackGroundColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
    else
      Brush.Style := bsClear;

    Font.Color := TextColor;

    lastSize := Font.Size;
    Font.Size := AndroidToLCLFontSize(jCheckBox(FAndroidWidget).FontSize, 12);
    TextOut(32, 14 - Abs(Font.Height) div 2, FAndroidWidget.Text);
    Font.Size := lastSize;

    Brush.Style := bsClear;
    Pen.Color := RGBToColor(155,155,155);
    Ellipse(7, 6, 25, 24);

    if jRadioButton(FAndroidWidget).Checked then
    begin
      Brush.Color := RGBToColor(0,$99,$CC);
      Ellipse(7+3, 6+3, 25-3, 24-3);
    end;
  end;
end;

procedure TDraftRadioButton.UpdateLayout;
var
  ps, ls: Integer;
begin
  with jRadioButton(FAndroidWidget) do
  begin
    if LayoutParamHeight = lpWrapContent then
      FMinHeight := 32;
    if LayoutParamWidth = lpWrapContent then
    begin
      ps := AndroidToLCLFontSize(FontSize, 12);
      ls := FCanvas.Font.Size;
      FCanvas.Font.Size := ps;
      FMinWidth := 33 + FCanvas.TextWidth(Text);
      FCanvas.Font.Size := ls;
    end;
  end;
  inherited UpdateLayout;
end;

{ TDraftProgressBar }

constructor TDraftProgressBar.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jProgressBar(AWidget).BackgroundColor;
  FontColor := colbrBlack;

  if jProgressBar(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftProgressBar.Draw;
var
  x: integer;
  r: TRect;
begin
  with Fcanvas do
  begin
    Brush.Color := RGBToColor($ad,$ad,$ad);
    r := Rect(0, 10, Self.Width, 13);
    FillRect(r);
    Brush.Color := RGBToColor($44,$B3,$DD);
    r.Top := 9;
    r.Bottom := 12;
    if jProgressBar(FAndroidWidget).Max <= 0 then
      jProgressBar(FAndroidWidget).Max := 100;
    x := Self.Width * jProgressBar(FAndroidWidget).Progress
         div jProgressBar(FAndroidWidget).Max;
    { "inverse" does not work... yet?
    if not (jProgressBar(FAndroidWidget).Style
            in [cjProgressBarStyleInverse, cjProgressBarStyleLargeInverse])
    then}
      r.Right := x
    {else begin
      r.Right := Self.Width;
      r.Left := Self.Width - x;
    end};
    FillRect(r);
  end;
end;

procedure TDraftProgressBar.UpdateLayout;
begin
  with jProgressBar(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
      FMinHeight := 23;
  inherited UpdateLayout;
end;


{ TDraftSeekBar }

constructor TDraftSeekBar.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jSeekBar(AWidget).BackgroundColor;
  FontColor := colbrBlack;

  if jSeekBar(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftSeekBar.Draw;
var
  x: integer;
  r: TRect;
begin
  with Fcanvas do
  begin
    Brush.Color := RGBToColor($ad,$ad,$ad);
    r := Rect(0, 10, Self.Width, 13);
    FillRect(r);
    Brush.Color := RGBToColor($44,$B3,$DD);
    r.Top := 9;
    r.Bottom := 12;
    if jSeekBar(FAndroidWidget).Max <= 0 then
      jSeekBar(FAndroidWidget).Max := 100;
    x := Self.Width * jSeekBar(FAndroidWidget).Progress div jSeekBar(FAndroidWidget).Max;
    { "inverse" does not work... yet?
    if not (jProgressBar(FAndroidWidget).Style
            in [cjProgressBarStyleInverse, cjProgressBarStyleLargeInverse])
    then}
      r.Right := x;
    {else begin
      r.Right := Self.Width;
      r.Left := Self.Width - x;
    end};
    FillRect(r);
    Brush.Color := RGBToColor($ff,$ff,$00);
    Ellipse(Rect(x, 6, x+12 , 18));
  end;
end;

procedure TDraftSeekBar.UpdateLayout;
begin
  with jSeekBar(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
      FMinHeight := 23;
  inherited UpdateLayout;
end;

{ TDraftListView }

constructor TDraftListView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jListView(AWidget).BackgroundColor;
  FontColor := jListView(AWidget).FontColor; //colbrBlack;

  if jListView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftListView.Draw;
var
  i, k: integer;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clActiveCaption;

  if  Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);

  Fcanvas.Brush.Style:= bsSolid;

  Fcanvas.Pen.Color:= clSilver;
  k:= Trunc(Self.Height/20);
  for i:= 1 to k-1 do
  begin
    Fcanvas.MoveTo(Self.Width{-Self.MarginRight+10}, {x2} Self.MarginTop+i*20); {y1}
    Fcanvas.LineTo(0,Self.MarginTop+i*20);  {x1, y1}
  end;

  //canvas.Brush.Style:= bsClear;
  //canvas.Font.Color:= Self.TextColor;
  //canvas.TextOut(5,4, txt);

end;

{ TDraftImageBtn }

function TDraftImageBtn.GetImage: TPortableNetworkGraphic;
begin
  if FImage <> nil then
    Result := FImage
  else
    with jImageBtn(FAndroidWidget) do
      if (Images <> nil)
      and (IndexImageUp >= 0) and (IndexImageUp < Images.Count) then
      begin
        FImage := Designer.ImageCache.GetImageAsPNG(Designer.AssetsDir + Images.Images[IndexImageUp]);
        Result := FImage;
      end else
        Result := nil;
end;

constructor TDraftImageBtn.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jImageBtn(AWidget).BackgroundColor;
  FontColor:= colbrGray;

  if jImageBtn(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftImageBtn.Draw;
begin
  if GetImage <> nil then
    Fcanvas.Brush.Color := BackGroundColor
  else
    Fcanvas.Brush.Color := clSilver; //clMedGray;
  Fcanvas.Pen.Color := clWhite;
  if Self.BackGroundColor <> clNone then
    Fcanvas.FillRect(Rect(0, 0, Width, Height));
  if GetImage <> nil then
    Fcanvas.Brush.Style := bsClear;
  // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);
  Fcanvas.Pen.Color := clWindowFrame;
  Fcanvas.Line(Self.Width-Self.MarginRight+3,   {x2}
               Self.MarginTop-3,                {y1}
               Self.Width-Self.MarginRight+3,   {x2}
               Self.Height-Self.MarginBottom+3);{y2}

  Fcanvas.Line(Self.Width-Self.MarginRight+3,   {x2}
               Self.Height-Self.MarginBottom+3, {y2}
               Self.MarginLeft-4,               {x1}
               Self.Height-Self.MarginBottom+3);{y2}
  if GetImage <> nil then
    Fcanvas.Draw(1, 1, GetImage);
end;

procedure TDraftImageBtn.UpdateLayout;
var
  im: TPortableNetworkGraphic;
begin
  im := GetImage;
  if im <> nil then
    with jImageBtn(FAndroidWidget) do
    begin
      FMinHeight := im.Height + 3;
      FMinWidth := im.Width + 3;
    end;
  inherited UpdateLayout;
end;

{ TDraftImageView }

function TDraftImageView.GetImage: TPortableNetworkGraphic;
begin
  if FImage <> nil then
    Result := FImage
  else
    with jImageView(FAndroidWidget) do
      if (Images <> nil)
      and (ImageIndex >= 0) and (ImageIndex < Images.Count) then
      begin
        FImage := Designer.ImageCache.GetImageAsPNG(Designer.AssetsDir + Images.Images[ImageIndex]);
        Result := FImage;
      end else
        Result := nil;
end;

constructor TDraftImageView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jImageView(AWidget).BackgroundColor;
  FontColor:= colbrGray;
  BackGroundColor:= clActiveCaption; //clMenuHighlight;

  if jImageView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftImageView.Draw;
begin
  if GetImage <> nil then
    Fcanvas.Draw(0, 0, GetImage)
  else
    inherited Draw;
end;

procedure TDraftImageView.UpdateLayout;
var
  im: TPortableNetworkGraphic;
begin
  im := GetImage;
  with jImageView(FAndroidWidget) do
  begin
    if im <> nil then
    begin
      if LayoutParamHeight = lpWrapContent then
        FMinHeight := im.Height;
      if LayoutParamWidth = lpWrapContent then
        FMinWidth := im.Width;
    end;
  end;
  inherited UpdateLayout;
end;

{ TDrafDrawingView }

constructor TDraftDrawingView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jDrawingView(AWidget).BackgroundColor;
  FontColor := colbrGray;
  BackGroundColor := clActiveCaption; //clMenuHighlight;

  if jDrawingView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftSurfaceView }

constructor TDraftSurfaceView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jSurfaceView(AWidget).BackgroundColor;
  FontColor := colbrGray;
  BackGroundColor := clActiveCaption; //clMenuHighlight;

  if jSurfaceView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftSpinner }

constructor TDraftSpinner.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jSpinner(AWidget).BackgroundColor;
  FontColor := jSpinner(AWidget).DropListBackgroundColor;
  DropListTextColor := jSpinner(AWidget).DropListTextColor;
  DropListBackgroundColor := jSpinner(AWidget).DropListBackgroundColor;
  SelectedFontColor := jSpinner(AWidget).SelectedFontColor;

  if jSpinner(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftSpinner.SetDropListBackgroundColor(Acolor: TARGBColorBridge);
begin
  FDropListBackgroundColor:= Acolor;
  if Acolor <> colbrDefault then
    DropListColor:= ToTColor(Acolor)
  else
    DropListColor:= clNone;
end;

procedure TDraftSpinner.SetDropListTextColor(Acolor: TARGBColorBridge);
var
  fpColor: TFPColor;
begin
  FDropListTextColor:= Acolor;
  if Acolor <> colbrDefault then
  begin
    fpColor:= ToTFPColor(Acolor);
    DropListFontColor:= FPColorToTColor(fpColor);
  end
  else DropListFontColor:= clNone;
end;

procedure TDraftSpinner.SetSelectedFontColor(Acolor: TARGBColorBridge);
var
  fpColor: TFPColor;
begin
  FSelectedFontColor:= Acolor;
  if Acolor <> colbrDefault then
  begin
    fpColor:= ToTFPColor(Acolor);
    SelectedTextColor:= FPColorToTColor(fpColor);
  end
  else SelectedTextColor:= clNone;
end;

procedure TDraftSpinner.Draw;
var
  saveColor: TColor;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= Self.DropListColor;

  if DropListColor = clNone then
     Fcanvas.Pen.Color:= clMedGray;

  if BackGroundColor = clNone then
     Fcanvas.Brush.Color:= clWhite;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);

  Fcanvas.Brush.Color:= Self.DropListColor; //clActiveCaption;

  if DropListColor = clNone then
     Fcanvas.Brush.Color:= clSilver;

  Fcanvas.Rectangle(Self.Width-47,0+7,Self.Width-7,Self.Height-7);
  saveColor:= Fcanvas.Brush.Color;

  Fcanvas.Brush.Style:= bsClear;
  Fcanvas.Pen.Color:= clWhite;
  Fcanvas.Rectangle(Self.Width-48,0+6,Self.Width-6,Self.Height-6);

  Fcanvas.Pen.Color:= Self.DropListFontColor;

  if saveColor <> clBlack then
     Fcanvas.Pen.Color:= clBlack
  else
     Fcanvas.Pen.Color:= clSilver;

  Fcanvas.Line(Self.Width-42, 12,Self.Width-11, 12);
  Fcanvas.Line(Self.Width-42-1, 12,Self.Width-42+31 div 2, Self.Height-12);
  Fcanvas.Line(Self.Width-42+31 div 2,Self.Height-12,Self.Width-11,12);

  Fcanvas.Font.Color:= Self.SelectedTextColor;
  if SelectedTextColor = clNone then
     Fcanvas.Font.Color:= clMedGray;

  //Fcanvas.TextOut(5,4,txt);
end;

{ TDraftWebView }

constructor TDraftWebView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jWebView(AWidget).BackgroundColor;
  BackGroundColor := clWhite;

  if jWebView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftWebView.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clTeal; //clGreen;//clActiveCaption;
  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame

  Fcanvas.Brush.Color:= clWhite;
  Fcanvas.Pen.Color:= clMoneyGreen;//clActiveCaption;

  Fcanvas.FillRect(5,5,Self.Width-5,25);
  Fcanvas.Rectangle(5,5,Self.Width-5,25);

  Fcanvas.FillRect (5,30,Trunc(Self.Width/2)-5,Self.Height-5);
  Fcanvas.Rectangle(5,30,Trunc(Self.Width/2)-5,Self.Height-5);

  Fcanvas.FillRect (Trunc(Self.Width/2),30,Self.Width-5,Trunc(0.5*Self.Height));
  Fcanvas.Rectangle(Trunc(Self.Width/2),30,Self.Width-5,Trunc(0.5*Self.Height));

  Fcanvas.FillRect (Trunc(Self.Width/2),Trunc(0.5*Self.Height)+5,Self.Width-5,Self.Height-5);
  Fcanvas.Rectangle(Trunc(Self.Width/2),Trunc(0.5*Self.Height)+5,Self.Width-5,Self.Height-5);
end;

{ TDraftScrollView }

constructor TDraftScrollView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jScrollView(AWidget).BackgroundColor;

  if jScrollView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftScrollView.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;

  if Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame

  Fcanvas.Brush.Style:= bsSolid;
  Fcanvas.Brush.Color:= clWhite;
  Fcanvas.FillRect(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Brush.Color:= clMedGray; //Self.BackGroundColor;
  Fcanvas.FillRect(Self.Width-20+5,5+25,Self.Width-5-5,Self.Height-5-25);

  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;
  Fcanvas.Frame(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Pen.Color:= clBlack; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,Self.Height-5-1);

  Fcanvas.Pen.Color:= clWindowFrame; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-5,5+25+1);
  Fcanvas.LineTo(Self.Width-5-5,Self.Height-5-25);
  Fcanvas.LineTo(Self.Width-20+5,Self.Height-5-25);
end;

{ TDraftHorizontalScrollView }

constructor TDraftHorizontalScrollView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jHorizontalScrollView(AWidget).BackgroundColor;

  if jHorizontalScrollView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftHorizontalScrollView.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clMedGray;

  if Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame
  Fcanvas.TextOut(12, 9, jHorizontalScrollView(FAndroidWidget).Text);

(*  TODO :: Horizontal!
  Fcanvas.Brush.Style:= bsSolid;
  Fcanvas.Brush.Color:= clWhite;
  Fcanvas.FillRect(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Brush.Color:= clMedGray; //Self.BackGroundColor;
  Fcanvas.FillRect(Self.Width-20+5,5+25,Self.Width-5-5,Self.Height-5-25);

  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;
  Fcanvas.Frame(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Pen.Color:= clBlack; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,Self.Height-5-1);

  Fcanvas.Pen.Color:= clWindowFrame; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-5,5+25+1);
  Fcanvas.LineTo(Self.Width-5-5,Self.Height-5-25);
  Fcanvas.LineTo(Self.Width-20+5,Self.Height-5-25);
  *)

end;

{ TDraftRadioGroup}

constructor TDraftRadioGroup.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jRadioGroup(AWidget).BackgroundColor;

  if jRadioGroup(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftRadioGroup.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;

  if Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame

  Fcanvas.TextOut(12, 9, jRadioGroup(FAndroidWidget).Text);
end;

{ TDraftRatingBar}

constructor TDraftRatingBar.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jRatingBar(AWidget).BackgroundColor;

  if jRatingBar(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftRatingBar.Draw;

  procedure DrawStar(cx, cy: Integer);
  const
    R1 = 18.8;
    R2 = 8.4;
  var
    i: Integer;
    p: array of TPoint;
  begin
    SetLength(p, 5*2);
    for i := 0 to 4 do
    begin
      with p[i * 2] do
      begin
        x := cx + Round(R1 * Sin(i * 72 * pi / 180));
        y := cy - Round(R1 * Cos(i * 72 * pi / 180));
      end;
      with p[i * 2 + 1] do
      begin
        x := cx + Round(R2 * Sin((i + 0.5) * 72 * pi / 180));
        y := cy - Round(R2 * Cos((i + 0.5) * 72 * pi / 180));
      end;
    end;
    with FCanvas.Brush do
    begin
      Style := bsSolid;
      Color := RGBToColor(183, 183, 183);
    end;
    with FCanvas.Pen do
    begin
      Style := psSolid;
      Width := 1;
      Color := BlendColors(BackGroundColor, 62/114, 2, 2, 2);
    end;
    FCanvas.Polygon(p);
  end;

var
  i: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := BackGroundColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
  end;
  for i := 0 to jRatingBar(FAndroidWidget).NumStars - 1 do
    DrawStar(24 + 48 * i, 6 + 19)
end;

procedure TDraftRatingBar.UpdateLayout;
begin
  with jRatingBar(FAndroidWidget) do
  begin
    if LayoutParamHeight = lpWrapContent then
      FMinHeight := 57;
    if LayoutParamWidth = lpWrapContent then
      FMinWidth := 48 * NumStars;
  end;
  inherited UpdateLayout;
end;

{ TDraftDigitalClock}

constructor TDraftDigitalClock.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jDigitalClock(AWidget).BackgroundColor;

  if jDigitalClock(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftAnalogClock }

constructor TDraftAnalogClock.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jAnalogClock(AWidget).BackgroundColor;

  if jAnalogClock(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftToggleButton }

constructor TDraftToggleButton.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  BackGroundColor := clActiveCaption;; //clMenuHighlight;
  Color := jToggleButton(AWidget).BackgroundColor;
  FontColor := colbrGray;

  FOnOff := jToggleButton(AWidget).State <> tsOff
  {
  if jToggleButton(AWidget).BackgroundColor = colbrDefault then
    if AWidget.Parent is jPanel then
    begin
      Color := jPanel(AWidget.Parent).BackgroundColor;
    end else
    if AWidget.Parent is jCustomDialog then
    begin
      Color := jCustomDialog(AWidget.Parent).BackgroundColor;
    end;
  }
end;

procedure TDraftToggleButton.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clWhite;
  Fcanvas.Font.Color:= Self.TextColor;

  if Self.BackGroundColor = clNone then
     Fcanvas.Brush.Color:= clSilver; //clMedGray;

  if Self.TextColor = clNone then
      Fcanvas.Font.Color:= clBlack;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);

  Fcanvas.Pen.Color:= clWindowFrame;
  if Self.FOnOff = True then  //on
  begin

    Fcanvas.Brush.Style:= bsSolid;
    Fcanvas.Brush.Color:= clSkyBlue;
    Fcanvas.FillRect(Self.MarginRight-4,
                    Self.MarginTop-3,
                    Self.Width-Self.MarginLeft+2,
                    Self.Height-Self.MarginBottom+3);

    Fcanvas.Brush.Style:= bsClear;
    Fcanvas.Pen.Color:= clWindowFrame;

     Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
             Self.MarginTop-3,  {y1}
             Self.Width-Self.MarginRight+3,  {x2}
             Self.Height-Self.MarginBottom+3); {y2}

     Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
             Self.Height-Self.MarginBottom+3,{y2}
             Self.MarginLeft-4,                {x1}
             Self.Height-Self.MarginBottom+3);  {y2}


     Fcanvas.Pen.Color:= clWhite;
     Fcanvas.Line(Self.MarginLeft-4, {x1}
                   Self.MarginTop-3,  {y1}
                   Self.MarginLeft-4, {x1}
                   Self.Height-Self.MarginBottom+3); {y2}

     Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
                Self.MarginTop-3,  {y1}
                Self.MarginLeft-4, {x1}
                Self.MarginTop-3);{y1}
  end
  else  //off
  begin
    (*
    Fcanvas.Brush.Style:= bsSolid;
    Fcanvas.Brush.Color:= clSkyBlue;
    Fcanvas.FillRect(Self.MarginRight-4,
                    Self.MarginTop-3,
                    Self.Width-Self.MarginLeft+2,
                    Self.Height-Self.MarginBottom+3);

    *)
    Fcanvas.Brush.Style:= bsClear;
    Fcanvas.Pen.Color:= clWindowFrame;

    //V
    Fcanvas.Line(Self.MarginLeft-4, {x1}
               Self.MarginTop-3,  {y1}
               Self.MarginLeft-4, {x1}
               Self.Height-Self.MarginBottom+3); {y2}

     //H
    Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
            Self.MarginTop-3,  {y1}
            Self.MarginLeft-4, {x1}
            Self.MarginTop-3);{y1}

    Fcanvas.Pen.Color:= clWhite;
    Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
            Self.MarginTop-3,  {y1}
            Self.Width-Self.MarginRight+3,  {x2}
            Self.Height-Self.MarginBottom+3); {y2}

    Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
            Self.Height-Self.MarginBottom+3,{y2}
            Self.MarginLeft-4,                {x1}
            Self.Height-Self.MarginBottom+3);  {y2}


  end;
end;

{ TDraftSwitchButton }

procedure TDraftSwitchButton.Draw;
var
  x, y, z, i, ps: Integer;
  r, rb: TRect;
  ts: TTextStyle;
  s: string;
begin
  with FCanvas do
  begin
    if BackGroundColor = clNone then
      BackGroundColor := GetBackGroundColor
    else begin
      Brush.Color := BackGroundColor;
      FillRect(0, 0, Self.Width, Self.Height);
    end;
    x := Self.Height div 2 - 12;
    Brush.Color := BlendColors(BackGroundColor, 0.7, 153,153,153);
    ps := Font.Size;
    Font.Size := 10;
    with jSwitchButton(FAndroidWidget) do
    begin
      y := TextWidth(TextOn);
      z := TextWidth(TextOff);
      if y < z then y := z;
      y := y + 22; // button width

      i := 2 * (y + 2);
      if i < 92 then i := 92;
      z := Self.Width - 2 - i;
      rb := Rect(z, x, z + i, x + 24);

      FillRect(rb);
      if State = tsOff then
      begin
        z := rb.Left + 1;
        Brush.Color := BlendColors(Self.BackgroundColor, 0.414, 153,153,153);
        Font.Color := RGBToColor(234,234,234);
        s := TextOff;
      end else begin
        z := rb.Right - 1 - y;
        Brush.Color := BlendColors(Self.BackgroundColor, 0.14, 11,153,200);
        Font.Color := clWhite;
        s := TextOn;
      end;
    end;
    r := Rect(z, x + 1, z + y, x + 23);
    FillRect(r);
    ts := TextStyle;
    ts.Layout := tlCenter;
    ts.Alignment := Classes.taCenter;
    TextRect(r, 0, 0, s, ts);
    Font.Size := ps;
  end;
end;

procedure TDraftSwitchButton.UpdateLayout;
var
  ps, x, y: Integer;
begin
  FMinHeight := 28;
  with jSwitchButton(FAndroidWidget) do
  begin
    if LayoutParamWidth = lpWrapContent then
      with FCanvas do
      begin
        ps := Font.Size;
        Font.Size := 10;
        x := TextWidth(TextOn);
        y := TextWidth(TextOff);
        if y > x then x := y;
        x := 2 * (x + 22 + 2);
        if x < 92 then x := 92;
        x := x + 4;
        FMinWidth := x;
        Font.Size := ps;
      end;
    if LayoutParamHeight = lpWrapContent then
      FMinHeight := 28
  end;
  inherited;
end;

{TDraftGridView}

constructor TDraftGridView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jGridView(AWidget).BackgroundColor;
  if jGridView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftGridView.Draw;
var
  i, k: integer;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clActiveCaption;

  if  Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
  // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);
  Fcanvas.Brush.Style:= bsSolid;
  Fcanvas.Pen.Color:= clSilver;

  //H lines
  k:= Trunc((Self.Height-Self.MarginTop-Self.MarginBottom)/70);
  for i:= 1 to k do
  begin
    Fcanvas.MoveTo(Self.Width-Self.MarginRight+10, {x2} Self.MarginTop+i*70); {y1}
    Fcanvas.LineTo(Self.MarginLeft-10,Self.MarginTop+i*70);  {x1, y1}
  end;

  //V  lines
  k:= Trunc((Self.Width-Self.MarginLeft-Self.MarginRight)/70);
  for i:= 1 to k do
  begin
    Fcanvas.MoveTo((Self.MarginLeft-10)+i*70, Self.MarginTop-10);  {x1, y1}
    Fcanvas.LineTo((Self.MarginLeft-10)+i*70, Self.Height); {y1}
  end;
end;

{ TDraftView }

constructor TDraftView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jView(AWidget).BackgroundColor;

  FontColor:= colbrGray;
  BackGroundColor:= clActiveCaption; //clMenuHighlight;

  if jView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

initialization
  DraftClassesMap := TDraftControlHash.Create(64); // should be power of 2 for efficiency
  RegisterPropertyEditor(TypeInfo(TARGBColorBridge), nil, '', TARGBColorBridgePropertyEditor);
  RegisterPropertyEditor(TypeInfo(jVisualControl), jVisualControl, 'Anchor', TAnchorPropertyEditor);
  RegisterComponentEditor(jForm, TAndroidFormSizeComponentEditor);
  RegisterPropertyEditor(TypeInfo(Integer), jForm, 'Width', TAndroidFormSizePropertyEditor);
  RegisterPropertyEditor(TypeInfo(Integer), jForm, 'Height', TAndroidFormSizePropertyEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), jImageList, 'Images', TjImageListImagesEditor);
  RegisterComponentEditor(jImageList, TjImageListEditor);
  RegisterComponentEditor(jCustomDialog, TjCustomDialogComponentEditor);
  RegisterPropertyEditor(TypeInfo(TImageListIndex), jControl, '', TImageIndexPropertyEditor);
  RegisterPropertyEditor(TypeInfo(jImageList), nil, '', TImageListPropertyEditor);

  // DraftClasses registeration:
  //  * default drawing and anchoring => use TDraftWidget
  //    (it is not needed to create draft class without custom drawing)
  //  * do not register custom draft class for default drawing w/o anchoring
  //    (default drawing is implemented in Mediator.Paint)
  RegisterAndroidWidgetDraftClass(jProgressBar, TDraftProgressBar);
  RegisterAndroidWidgetDraftClass(jSeekBar, TDraftSeekBar);
  RegisterAndroidWidgetDraftClass(jButton, TDraftButton);
  RegisterAndroidWidgetDraftClass(jCheckBox, TDraftCheckBox);
  RegisterAndroidWidgetDraftClass(jRadioButton, TDraftRadioButton);
  RegisterAndroidWidgetDraftClass(jTextView, TDraftTextView);
  RegisterAndroidWidgetDraftClass(jPanel, TDraftPanel);
  RegisterAndroidWidgetDraftClass(jEditText, TDraftEditText);
  RegisterAndroidWidgetDraftClass(jToggleButton, TDraftToggleButton);
  RegisterAndroidWidgetDraftClass(jSwitchButton, TDraftSwitchButton);
  RegisterAndroidWidgetDraftClass(jListView, TDraftListView);
  RegisterAndroidWidgetDraftClass(jGridView, TDraftGridView);
  RegisterAndroidWidgetDraftClass(jImageBtn, TDraftImageBtn);
  RegisterAndroidWidgetDraftClass(jImageView, TDraftImageView);
  RegisterAndroidWidgetDraftClass(jSurfaceView, TDraftSurfaceView);
  RegisterAndroidWidgetDraftClass(jWebView, TDraftWebView);
  RegisterAndroidWidgetDraftClass(jScrollView, TDraftScrollView);
  RegisterAndroidWidgetDraftClass(jHorizontalScrollView, TDraftHorizontalScrollView);
  RegisterAndroidWidgetDraftClass(jRadioGroup, TDraftRadioGroup);
  RegisterAndroidWidgetDraftClass(jRatingBar, TDraftRatingBar);
  RegisterAndroidWidgetDraftClass(jAnalogClock, TDraftAnalogClock);
  RegisterAndroidWidgetDraftClass(jDigitalClock, TDraftDigitalClock);
  RegisterAndroidWidgetDraftClass(jSpinner, TDraftSpinner);
  RegisterAndroidWidgetDraftClass(jView, TDraftView);
  RegisterAndroidWidgetDraftClass(jAutoTextView, TDraftAutoTextView);
  RegisterAndroidWidgetDraftClass(jDrawingView, TDraftDrawingView);

  // TODO :: (default drawing and layout)
  RegisterAndroidWidgetDraftClass(jCanvasES1, TDraftWidget);
  RegisterAndroidWidgetDraftClass(jCanvasES2, TDraftWidget);
  RegisterAndroidWidgetDraftClass(jChronometer, TDraftWidget);
  RegisterAndroidWidgetDraftClass(jViewFlipper, TDraftWidget);
  RegisterAndroidWidgetDraftClass(jVideoView, TDraftWidget);

finalization
  DraftClassesMap.Free;
end.

