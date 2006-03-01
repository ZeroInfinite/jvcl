{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvDBActions.Pas, released on 2004-12-30.

The Initial Developer of the Original Code is Jens Fudickar [jens dott fudicker  att oratool dott de]
Portions created by Jens Fudickar are Copyright (C) 2002 Jens Fudickar.
All Rights Reserved.

Contributor(s): -

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}
// $Id$

unit JvDBActions;

{$I jvcl.inc}

interface

uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  {$IFDEF MSWINDOWS}
  Windows, ActnList, ImgList, Graphics,
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  QActnList, QWindows, QImgList, QGraphics,
  {$ENDIF UNIX}
  Forms, Controls, Classes, DB,
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  cxGridCustomTableView,
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  {$IFDEF USE_3RDPARTY_SMEXPORT}
  SMEWIZ, ExportDS, SMEEngine,
  {$ENDIF USE_3RDPARTY_SMEXPORT}
  {$IFDEF USE_3RDPARTY_SMIMPORT}
  SMIWiz, SMIBase,
  {$ENDIF USE_3RDPARTY_SMIMPORT}
  DBGrids, JvPanel, JvDynControlEngineDB, JvDynControlEngineDBTools;

type
  TComponentClass = class of TComponent;

  TJvChangeDataComponent = procedure(DataComponent: TComponent) of object;

  TJvShowSingleRecordWindowOptions = class(TPersistent)
  private
    FDialogCaption: string;
    FPostButtonCaption: string;
    FCancelButtonCaption: string;
    FCloseButtonCaption: string;
    FBorderStyle: TFormBorderStyle;
    FPosition: TPosition;
    FTop: integer;
    FLeft: integer;
    FWidth: integer;
    FHeight: integer;
    FArrangeConstraints: TSizeConstraints;
    FArrangeSettings: TJvArrangeSettings;
    FFieldCreateOptions: TJvCreateDBFieldsOnControlOptions;
  protected
    procedure SetArrangeSettings(Value: TJvArrangeSettings);
    procedure SetArrangeConstraints(Value: TSizeConstraints);
    procedure SetFieldCreateOptions(Value: TJvCreateDBFieldsOnControlOptions);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetOptionsToDialog(ADialog: TJvDynControlDataSourceEditDialog);
  published
    property DialogCaption: string Read FDialogCaption Write FDialogCaption;
    property PostButtonCaption: string Read FPostButtonCaption Write FPostButtonCaption;
    property CancelButtonCaption: string Read FCancelButtonCaption Write FCancelButtonCaption;
    property CloseButtonCaption: string Read FCloseButtonCaption Write FCloseButtonCaption;
    property BorderStyle: TFormBorderStyle Read FBorderStyle Write FBorderStyle default bsDialog;
    property Position: TPosition Read FPosition Write FPosition default poScreenCenter;
    property Top: integer Read FTop Write FTop default 0;
    property Left: integer Read FLeft Write FLeft default 0;
    property Width: integer Read FWidth Write FWidth default 640;
    property Height: integer Read FHeight Write FHeight default 480;
    property ArrangeConstraints: TSizeConstraints Read FArrangeConstraints Write SetArrangeConstraints;
    property ArrangeSettings: TJvArrangeSettings Read FArrangeSettings Write SetArrangeSettings;
    property FieldCreateOptions: TJvCreateDBFieldsOnControlOptions Read FFieldCreateOptions
      Write SetFieldCreateOptions;
  end;

  TJvDatabaseActionList = class(TActionList)
  private
    FDataComponent: TComponent;
    FOnChangeDataComponent: TJvChangeDataComponent;
  protected
    procedure SetDataComponent(Value: TComponent);
  public
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    property DataComponent: TComponent Read FDataComponent Write SetDataComponent;
    property OnChangeDataComponent: TJvChangeDataComponent read
        FOnChangeDataComponent write FOnChangeDataComponent;
  end;

  TJvDatabaseActionBaseEngine = class(TComponent)
  private
    FDatacomponent: TComponent;
    FDataset: TDataset;
    FDataSource: TDataSource;
    function GetSelectedField: TField; virtual;
    procedure SetDatacomponent(const Value: TComponent); virtual;
  protected
    function GetDataSource(ADataComponent: TComponent): TDataSource; virtual;
    function GetDataSet(ADataComponent: TComponent): TDataSet; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    function Supports(ADataComponent: TComponent): boolean; virtual;
    function IsActive: boolean; virtual;
    function HasData: boolean; virtual;
    function FieldCount: integer; virtual;
    function RecordCount: integer; virtual;
    function RecNo: integer; virtual;
    function CanInsert: boolean; virtual;
    function CanUpdate: boolean; virtual;
    function CanDelete: boolean; virtual;
    function EOF: boolean; virtual;
    function Bof: boolean; virtual;
    procedure DisableControls; virtual;
    procedure EnableControls; virtual;
    function ControlsDisabled: boolean; virtual;
    function EditModeActive: boolean; virtual;
    function FieldById(const FieldId : Integer): TField; virtual;
    function FieldByName(const FieldName : String): TField; virtual;
    procedure FillFieldList(var AFieldList: TStrings; const AOnlyVisible: Boolean);
        virtual;
    procedure First; virtual;
    procedure GotoSelectedRow(const ASelectedRow: Integer); virtual;
    function IsFieldVisible(const AFieldName : String): Boolean; virtual;
    function IsFieldReadOnly(const AFieldName : String): Boolean; virtual;
    procedure Last; virtual;
    procedure MoveBy(Distance : Integer); virtual;
    function SelectedRowsCount: Integer; virtual;
    procedure ShowSingleRecordWindow(AOptions: TJvShowSingleRecordWindowOptions);
        virtual;
    property Datacomponent: TComponent read FDatacomponent write SetDatacomponent;
    property Dataset: TDataset read FDataset;
    property DataSource: TDataSource read FDataSource;
    property SelectedField: TField read GetSelectedField;
  end;

  TJvDatabaseActionBaseEngineClass = class of TJvDatabaseActionBaseEngine;

  TJvDatabaseActionDBGridEngine = class(TJvDatabaseActionBaseEngine)
  private
    FCustomDBGrid: TCustomDBGrid;
  protected
    function GetCustomDBGrid(ADataComponent: TComponent): TCustomDBGrid; virtual;
    function GetDataSource(ADataComponent: TComponent): TDataSource; override;
    procedure OnCreateDataControls(ADynControlEngineDB: TJvDynControlEngineDB;
      AParentControl: TWinControl; AFieldCreateOptions: TJvCreateDBFieldsOnControlOptions);
    procedure SetDatacomponent(const Value : TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure GotoSelectedRow(const ASelectedRow: Integer); override;
    function GetSelectedField: TField; override;
    function SelectedRowsCount: Integer; override;
    function Supports(ADataComponent: TComponent): boolean; override;
    procedure ShowSingleRecordWindow(AOptions: TJvShowSingleRecordWindowOptions);
        override;
    property CustomDBGrid: TCustomDBGrid read FCustomDBGrid;
  end;

  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  TJvDatabaseActionDevExpCxGridEngine = class(TJvDatabaseActionBaseEngine)
  private
    FGridView: TcxCustomGridTableView;
  protected
    function GetGridView(ADataComponent: TComponent): TcxCustomGridTableView;
    function GetDataSource(ADataComponent: TComponent): TDataSource; override;
    procedure SetDatacomponent(const Value : TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    function Bof: boolean; override;
    function RecNo: integer; override;
    function RecordCount: integer; override;
    function CanInsert: boolean; override;
    function CanUpdate: boolean; override;
    function CanDelete: boolean; override;
    procedure First; override;
    procedure GotoSelectedRow(const ASelectedRow: Integer); override;
    procedure Last; override;
    procedure MoveBy(Distance : Integer); override;
    function SelectedRowsCount: Integer; override;
    function Supports(ADataComponent: TComponent): boolean; override;
    property GridView: TcxCustomGridTableView read FGridView;
  end;

  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}

  TJvDatabaseExecuteEvent = procedure(Sender: TObject; DataEngine: TJvDatabaseActionBaseEngine;
    DataComponent: TComponent) of object;
  TJvDatabaseExecuteDataSourceEvent = procedure(Sender: TObject; DataSource: TDataSource) of object;

  TJvDatabaseBaseAction = class(TAction)
  private
    FOnExecute: TJvDatabaseExecuteEvent;
    FOnExecuteDataSource: TJvDatabaseExecuteDataSourceEvent;
    FDataEngine: TJvDatabaseActionBaseEngine;
    FDataComponent: TComponent;
    FOnChangeDataComponent: TJvChangeDataComponent;
  protected
    procedure SetDataComponent(Value: TComponent);
    procedure SetEnabled(Value: boolean);
    function GetDataSet: TDataSet;
    function GetDataSource: TDataSource;
    function EngineIsActive: boolean;
    function EngineHasData: boolean;
    function EngineFieldCount: integer;
    function EngineRecordCount: integer;
    function EngineRecNo: integer;
    function EngineCanInsert: boolean;
    function EngineCanUpdate: boolean;
    function EngineCanDelete: boolean;
    function EngineEof: boolean;
    function EngineBof: boolean;
    function EngineControlsDisabled: boolean;
    function EngineEditModeActive: boolean;
    function EngineSelectedRowsCount: integer;
    property DataEngine: TJvDatabaseActionBaseEngine Read FDataEngine;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateTarget(Target: TObject); override;
    function HandlesTarget(Target: TObject): boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property DataSource: TDataSource Read GetDataSource;
    property DataSet: TDataSet Read GetDataSet;
  published
    property OnChangeDataComponent: TJvChangeDataComponent read
        FOnChangeDataComponent write FOnChangeDataComponent;
    property OnExecute: TJvDatabaseExecuteEvent Read FOnExecute Write FOnExecute;
    property OnExecuteDataSource: TJvDatabaseExecuteDataSourceEvent
      Read FOnExecuteDataSource Write FOnExecuteDataSource;
    property DataComponent: TComponent Read FDataComponent Write SetDataComponent;
  end;

  TJvDatabaseSimpleAction = class(TJvDatabaseBaseAction)
  private
    FIsActive: boolean;
    FHasData: boolean;
    FCanInsert: boolean;
    FCanUpdate: boolean;
    FCanDelete: boolean;
    FEditModeActive: boolean;
    FManualEnabled: Boolean;
    procedure SetManualEnabled(const Value: Boolean);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateTarget(Target: TObject); override;
  published
    // If this paramater is active, the Action will be enabled if for the datacomponent-dataset is active
    property IsActive: boolean Read FIsActive Write FIsActive default True;
    // If this paramater is active, the Action will be enabled if for the datacomponent-dataset contains records
    property HasData: boolean Read FHasData Write FHasData default True;
    // If this paramater is active, the Action will be enabled if insert is allowed for the datacomponent-dataset
    property CanInsert: boolean Read FCanInsert Write FCanInsert default False;
    // If this paramater is active, the Action will be enabled if update is allowed for the datacomponent-dataset
    property CanUpdate: boolean Read FCanUpdate Write FCanUpdate default False;
    // If this paramater is active, the Action will be enabled if delete is allowed for the datacomponent-dataset
    property CanDelete: boolean Read FCanDelete Write FCanDelete default False;
    // If this paramater is active, the Action will be enabled if the datacomponent-dataset is in edit mode
    property EditModeActive: boolean Read FEditModeActive Write FEditModeActive default False;
    // This property allows you enable / disable the action independently from the
    // automatic handling by IsActive, HasData, CanInsert, CanUpdate, EditModeActive
    property ManualEnabled: Boolean read FManualEnabled write SetManualEnabled
        default True;
  end;

  TJvDatabaseBaseActiveAction = class(TJvDatabaseBaseAction)
  public
    procedure UpdateTarget(Target: TObject); override;
  end;

  TJvDatabaseBaseEditAction = class(TJvDatabaseBaseActiveAction)
  public
    procedure UpdateTarget(Target: TObject); override;
  end;

  TJvDatabaseBaseNavigateAction = class(TJvDatabaseBaseActiveAction)
  end;

  TJvDatabaseFirstAction = class(TJvDatabaseBaseNavigateAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseLastAction = class(TJvDatabaseBaseNavigateAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabasePriorAction = class(TJvDatabaseBaseNavigateAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseNextAction = class(TJvDatabaseBaseNavigateAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabasePriorBlockAction = class(TJvDatabaseBaseNavigateAction)
  public
    FBlockSize: integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property BlockSize: integer Read FBlockSize Write FBlockSize default 50;
  end;

  TJvDatabaseNextBlockAction = class(TJvDatabaseBaseNavigateAction)
  private
    FBlockSize: integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property BlockSize: integer Read FBlockSize Write FBlockSize default 50;
  end;

  TJvDatabaseRefreshAction = class(TJvDatabaseBaseActiveAction)
  private
    FRefreshLastPosition: boolean;
    FRefreshAsOpenClose: boolean;
  protected
    procedure Refresh;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property RefreshLastPosition: boolean Read FRefreshLastPosition Write FRefreshLastPosition default True;
    property RefreshAsOpenClose: boolean Read FRefreshAsOpenClose Write FRefreshAsOpenClose default False;
  end;

  TJvDatabasePositionAction = class(TJvDatabaseBaseNavigateAction)
  protected
    procedure SetCaption(Value: string);
  public
    procedure ShowPositionDialog;
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseInsertAction = class(TJvDatabaseBaseEditAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseOnCopyRecord = procedure(Field: TField; OldValue: variant) of object;
  TJvDatabaseBeforeCopyRecord = procedure(DataSet: TDataSet; var RefreshAllowed: boolean) of object;
  TJvDatabaseAfterCopyRecord = procedure(DataSet: TDataSet) of object;

  TJvDatabaseCopyAction = class(TJvDatabaseBaseEditAction)
  private
    FBeforeCopyRecord: TJvDatabaseBeforeCopyRecord;
    FAfterCopyRecord: TJvDatabaseAfterCopyRecord;
    FOnCopyRecord: TJvDatabaseOnCopyRecord;
  public
    procedure CopyRecord;
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property BeforeCopyRecord: TJvDatabaseBeforeCopyRecord Read FBeforeCopyRecord Write FBeforeCopyRecord;
    property AfterCopyRecord: TJvDatabaseAfterCopyRecord Read FAfterCopyRecord Write FAfterCopyRecord;
    property OnCopyRecord: TJvDatabaseOnCopyRecord Read FOnCopyRecord Write FOnCopyRecord;
  end;

  TJvDatabaseEditAction = class(TJvDatabaseBaseEditAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseDeleteAction = class(TJvDatabaseBaseEditAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabasePostAction = class(TJvDatabaseBaseEditAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseCancelAction = class(TJvDatabaseBaseEditAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseSingleRecordWindowAction = class(TJvDatabaseBaseActiveAction)
  private
    FOptions: TJvShowSingleRecordWindowOptions;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteTarget(Target: TObject); override;
    procedure ShowSingleRecordWindow;
  published
    property Options: TJvShowSingleRecordWindowOptions Read FOptions Write FOptions;
  end;

  TJvDatabaseOpenAction = class(TJvDatabaseBaseActiveAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TJvDatabaseCloseAction = class(TJvDatabaseBaseActiveAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  {$IFDEF USE_3RDPARTY_SMEXPORT}

  TJvDatabaseSMExportOptions = class(TPersistent)
  private
    FHelpContext: THelpContext;
    FFormats: TExportFormatTypes;
    FTitle: TCaption;
    FDefaultOptionsDirectory: string;
    FKeyGenerator: string;
    FOptions: TSMOptions;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SMEWizardDlgGetCellParams(Sender: TObject; Field: TField; var Text: string;
      AFont: TFont; var Alignment: TAlignment; var Background: TColor; var CellType: TCellType);
    procedure SMEWizardDlgOnBeforeExecute(Sender: TObject);
  published
    property HelpContext: THelpContext Read FHelpContext Write FHelpContext;
    property Formats: TExportFormatTypes Read FFormats Write FFormats;
    property Title: TCaption Read FTitle Write FTitle;
    property DefaultOptionsDirectory: string Read FDefaultOptionsDirectory Write FDefaultOptionsDirectory;
    property KeyGenerator: string Read FKeyGenerator Write FKeyGenerator;
    property Options: TSMOptions Read FOptions Write FOptions;
  end;

  TJvDatabaseSMExportAction = class(TJvDatabaseBaseActiveAction)
  private
    FOptions: TJvDatabaseSMExportOptions;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteTarget(Target: TObject); override;
    procedure ExportData;
  published
    property Options: TJvDatabaseSMExportOptions Read FOptions Write FOptions;
  end;

  {$ENDIF USE_3RDPARTY_SMEXPORT}

  {$IFDEF USE_3RDPARTY_SMIMPORT}

  TJvDatabaseSMImportOptions = class(TPersistent)
  private
    FHelpContext: THelpContext;
    FFormats: TImportFormatTypes;
    FTitle: TCaption;
    FDefaultOptionsDirectory: string;
    FOptions: TSMIOptions;
    FWizardStyle: TSMIWizardStyle;
  public
    constructor Create;
  published
    property HelpContext: THelpContext Read FHelpContext Write FHelpContext;
    property Formats: TImportFormatTypes Read FFormats Write FFormats;
    property Title: TCaption Read FTitle Write FTitle;
    property DefaultOptionsDirectory: string Read FDefaultOptionsDirectory Write FDefaultOptionsDirectory;
    property Options: TSMIOptions Read FOptions Write FOptions;
    property WizardStyle: TSMIWizardStyle Read FWizardStyle Write FWizardStyle;
  end;

  TJvDatabaseSMImportAction = class(TJvDatabaseBaseEditAction)
  private
    FOptions: TJvDatabaseSMImportOptions;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteTarget(Target: TObject); override;
    procedure ImportData;
  published
    property Options: TJvDatabaseSMImportOptions Read FOptions Write FOptions;
  end;

  {$ENDIF USE_3RDPARTY_SMIMPORT}

  TJvDatabaseActionEngineList = class(TList)
  public
    destructor Destroy; override;
    procedure RegisterEngine(AEngineClass: TJvDatabaseActionBaseEngineClass);
    function GetEngine(AComponent: TComponent): TJvDatabaseActionBaseEngine;
    function Supports(AComponent: TComponent): boolean;
  end;

  TJvDatabaseModifyAllAction = class(TJvDatabaseBaseEditAction)
  private
    FEnabledOnlyIfSelectedRows: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ExecuteTarget(Target: TObject); override;
    procedure ModifyAll;
    procedure UpdateTarget(Target: TObject); override;
  published
    property EnabledOnlyIfSelectedRows: Boolean read FEnabledOnlyIfSelectedRows
        write FEnabledOnlyIfSelectedRows default True;
  end;

procedure RegisterActionEngine(AEngineClass: TJvDatabaseActionBaseEngineClass);

function RegisteredDatabaseActionEngineList: TJvDatabaseActionEngineList;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$RCSfile$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  SysUtils, Grids,
  {$IFDEF HAS_UNIT_STRUTILS}
  StrUtils,
  {$ENDIF HAS_UNIT_STRUTILS}
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  cxGrid, cxGridDBDataDefinitions,
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  {$IFDEF USE_3RDPARTY_SMEXPORT}
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  SMEEngCx,
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  sme2sql, IniFiles,
  {$ENDIF USE_3RDPARTY_SMEXPORT}
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  cxCustomData,
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  JvResources, JvParameterList, JvParameterListParameter, TypInfo,
  JvDSADialogs, Dialogs;

var
  IntRegisteredActionEngineList: TJvDatabaseActionEngineList;

//=== { TJvDatabaseActionList } ==============================================

procedure TJvDatabaseActionList.SetDataComponent(Value: TComponent);
var
  I: integer;
begin
  if Value <> FDataComponent then
  begin
    FDataComponent := Value;
    if FDataComponent <> nil then
      FDataComponent.FreeNotification(Self);
    for I := 0 to ActionCount - 1 do
      if Actions[I] is TJvDatabaseBaseAction then
        TJvDatabaseBaseAction(Actions[I]).DataComponent := Value;
    if Assigned(OnChangeDataComponent) then
      OnChangeDataComponent (Value);
  end;
end;

procedure TJvDatabaseActionList.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
    if AComponent = FDataComponent then
      DataComponent := nil;
end;

//=== { TJvShowSingleRecordWindowOptions } ===================================

constructor TJvShowSingleRecordWindowOptions.Create;
begin
  inherited Create;
  FDialogCaption := '';
  FPostButtonCaption := RsSRWPostButtonCaption;
  FCancelButtonCaption := RsSRWCancelButtonCaption;
  FCloseButtonCaption := RsSRWCloseButtonCaption;
  FBorderStyle := bsDialog;
  FTop      := 0;
  FLeft     := 0;
  FWidth    := 640;
  FHeight   := 480;
  FPosition := poScreenCenter;
  FArrangeSettings := TJvArrangeSettings.Create();
  with FArrangeSettings do
  begin
    AutoSize     := asBoth;
    DistanceHorizontal := 3;
    DistanceVertical := 3;
    BorderLeft   := 3;
    BorderTop    := 3;
    WrapControls := True;
  end;
  FArrangeConstraints := TSizeConstraints.Create(nil);
  FArrangeConstraints.MaxHeight := 480;
  FArrangeConstraints.MaxWidth := 640;
  FFieldCreateOptions := TJvCreateDBFieldsOnControlOptions.Create;
end;

destructor TJvShowSingleRecordWindowOptions.Destroy;
begin
  FFieldCreateOptions.Free;
  FArrangeConstraints.Free;
  FArrangeSettings.Free;
  inherited Destroy;
end;

procedure TJvShowSingleRecordWindowOptions.SetArrangeSettings(Value: TJvArrangeSettings);
begin
  FArrangeSettings.Assign(Value);
end;

procedure TJvShowSingleRecordWindowOptions.SetArrangeConstraints(Value: TSizeConstraints);
begin
  FArrangeConstraints.Assign(Value);
end;

procedure TJvShowSingleRecordWindowOptions.SetFieldCreateOptions(Value: TJvCreateDBFieldsOnControlOptions);
begin
  FFieldCreateOptions.Assign(Value);
end;

procedure TJvShowSingleRecordWindowOptions.SetOptionsToDialog(ADialog: TJvDynControlDataSourceEditDialog);
begin
  if Assigned(ADialog) then
  begin
    ADialog.DialogCaption := DialogCaption;
    ADialog.PostButtonCaption := PostButtonCaption;
    ADialog.CancelButtonCaption := CancelButtonCaption;
    ADialog.CloseButtonCaption := CloseButtonCaption;
    ADialog.Position := Position;
    ADialog.BorderStyle := BorderStyle;
    ADialog.Top    := Top;
    ADialog.Left   := Left;
    ADialog.Width  := Width;
    ADialog.Height := Height;
    ADialog.ArrangeConstraints := ArrangeConstraints;
    ADialog.ArrangeSettings := ArrangeSettings;
    ADialog.FieldCreateOptions := FieldCreateOptions;
  end;
end;

constructor TJvDatabaseActionBaseEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataset := nil;
  FDataSource := nil;
  FDatacomponent := nil;
end;

//=== { TJvDatabaseActionBaseEngine } ========================================

function TJvDatabaseActionBaseEngine.GetDataSource(ADataComponent: TComponent):
    TDataSource;
begin
  if Assigned(ADataComponent) and (ADataComponent is TDataSource) then
    Result := TDataSource(ADataComponent)
  else
    Result := nil;
end;

function TJvDatabaseActionBaseEngine.GetDataSet(ADataComponent: TComponent):
    TDataSet;
begin
  if Assigned(GetDataSource(ADataComponent)) then
    Result := GetDataSource(ADataComponent).DataSet
  else
    Result := nil;
end;

function TJvDatabaseActionBaseEngine.Supports(ADataComponent: TComponent): boolean;
begin
  Result := Assigned(ADataComponent) and (ADataComponent is TDataSource);
end;

function TJvDatabaseActionBaseEngine.IsActive: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.Active
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.HasData: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.RecordCount > 0
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.FieldCount: integer;
begin
  if Assigned(DataSet) then
    Result := DataSet.FieldCount
  else
    Result := -1;
end;

function TJvDatabaseActionBaseEngine.RecordCount: integer;
begin
  if Assigned(DataSet) then
    Result := DataSet.RecordCount
  else
    Result := -1;
end;

function TJvDatabaseActionBaseEngine.RecNo: integer;
begin
  if Assigned(DataSet) then
    Result := DataSet.RecNo
  else
    Result := -1;
end;

function TJvDatabaseActionBaseEngine.CanInsert: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.CanModify
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.CanUpdate: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.CanModify
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.CanDelete: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.CanModify
  else
    Result := False;
end;


function TJvDatabaseActionBaseEngine.EOF: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.EOF
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.Bof: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.Bof
  else
    Result := False;
end;

procedure TJvDatabaseActionBaseEngine.DisableControls;
begin
  if Assigned(DataSet) then
    DataSet.DisableControls;
end;

procedure TJvDatabaseActionBaseEngine.EnableControls;
begin
  if Assigned(DataSet) then
    DataSet.EnableControls;
end;

function TJvDatabaseActionBaseEngine.ControlsDisabled: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.ControlsDisabled
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.EditModeActive: boolean;
begin
  if Assigned(DataSet) then
    Result := DataSet.State in [dsInsert, dsEdit]
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.FieldById(const FieldId : Integer): TField;
begin
  if Assigned(Dataset) then
    Result := Dataset.Fields[FieldId]
  else
    Result := nil;
end;

function TJvDatabaseActionBaseEngine.FieldByName(const FieldName : String):
    TField;
begin
  if Assigned(Dataset) then
    Result := Dataset.FieldByName(FieldName)
  else
    Result := nil;
end;

procedure TJvDatabaseActionBaseEngine.FillFieldList(var AFieldList: TStrings;
    const AOnlyVisible: Boolean);
var
  i: Integer;
begin
  AFieldList.Clear;
  if Assigned(Dataset) then
  begin
    for i := 0 to DataSet.Fields.Count - 1 do
      if not AOnlyVisible or IsFieldVisible(DataSet.Fields[i].FieldName) then
        AFieldList.Add(DataSet.Fields[i].FieldName);
  end;
end;

procedure TJvDatabaseActionBaseEngine.First;
begin
  if Assigned(DataSet) then
    DataSet.First;
end;

procedure TJvDatabaseActionBaseEngine.GotoSelectedRow(const ASelectedRow:
    Integer);
begin
  
end;

function TJvDatabaseActionBaseEngine.IsFieldVisible(const AFieldName : String):
    Boolean;
var Field : TField;
begin
  Field := FieldByName(AFieldName);
  if Assigned(Field) then
    Result := Field.Visible
  else
    Result := False;
end;

function TJvDatabaseActionBaseEngine.IsFieldReadOnly(const AFieldName :
    String): Boolean;
var Field : TField;
begin
  Field := FieldByName(AFieldName);
  if Assigned(Field) then
    Result := Field.ReadOnly
  else
    Result := False;
end;

procedure TJvDatabaseActionBaseEngine.Last;
begin
  if Assigned(DataSet) then
    DataSet.Last;
end;

procedure TJvDatabaseActionBaseEngine.MoveBy(Distance : Integer);
begin
  if Assigned(DataSet) then
    DataSet.MoveBy(Distance);
end;

procedure TJvDatabaseActionBaseEngine.Notification(AComponent: TComponent;
    Operation: TOperation);
begin
  inherited Notification (AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataComponent) then
    DataComponent := nil;
end;

function TJvDatabaseActionBaseEngine.GetSelectedField: TField;
begin
  Result := nil;
end;

function TJvDatabaseActionBaseEngine.SelectedRowsCount: Integer;
begin
  Result := 0;
end;

procedure TJvDatabaseActionBaseEngine.SetDatacomponent(const Value: TComponent);
begin
  FDatacomponent := Value;
  FDatasource := GetDataSource (Value);
  FDataset := GetDataSet (Value);
  if FDataComponent <> nil then
    FDataComponent.FreeNotification(Self);
end;

procedure TJvDatabaseActionBaseEngine.ShowSingleRecordWindow(AOptions:
    TJvShowSingleRecordWindowOptions);
var
  Dialog: TJvDynControlDataSourceEditDialog;
begin
  Dialog := TJvDynControlDataSourceEditDialog.Create;
  try
    AOptions.SetOptionsToDialog(Dialog);
    if Dialog.DynControlEngineDB.SupportsDataComponent(DataComponent) then
      Dialog.DataComponent := DataComponent
    else
      Dialog.DataComponent := DataSource;
    Dialog.ShowDialog;
  finally
    Dialog.Free;
  end;
end;

//=== { TJvDatabaseActionDBGridEngine } ======================================

function TJvDatabaseActionDBGridEngine.GetDataSource(ADataComponent:
    TComponent): TDataSource;
begin
  if Assigned(ADataComponent) and (ADataComponent is TCustomDBGrid) then
    Result := TCustomDBGrid(ADataComponent).DataSource
  else
    Result := nil;
end;

type
  TAccessCustomDBGrid = class(TCustomDBGrid);
  TAccessCustomControl = class(TCustomControl);

constructor TJvDatabaseActionDBGridEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCustomDBGrid := nil;
end;

function TJvDatabaseActionDBGridEngine.GetCustomDBGrid(ADataComponent:
    TComponent): TCustomDBGrid;
begin
  if Assigned(ADataComponent) and (ADataComponent is TCustomDBGrid) then
    Result := TCustomDBGrid(ADataComponent)
  else
    Result := nil;
end;

procedure TJvDatabaseActionDBGridEngine.GotoSelectedRow(const ASelectedRow:
    Integer);
begin
  if (ASelectedRow >= 0) and (ASelectedRow < SelectedRowsCount) then
    if Assigned(Dataset) and Dataset.Active then
      Dataset.GotoBookmark(Pointer(TAccessCustomDBGrid(CustomDBGrid).SelectedRows[ASelectedRow]));
end;

procedure TJvDatabaseActionDBGridEngine.OnCreateDataControls(ADynControlEngineDB: TJvDynControlEngineDB;
  AParentControl: TWinControl; AFieldCreateOptions: TJvCreateDBFieldsOnControlOptions);
var
  I:      integer;
  ds:     TDataSource;
  Field:  TField;
  LabelControl: TControl;
  Control: TWinControl;
  Column: TColumn;
begin
  if Assigned(CustomDBGrid) then
  begin
    ds := DataSource;
    with AFieldCreateOptions do
      for I := 0 to TAccessCustomDBGrid(CustomDBGrid).ColCount - 2 do
      begin
        Column := TAccessCustomDBGrid(CustomDBGrid).Columns[I];
        if Column.Visible or ShowInvisibleFields then
        begin
          Field   := Column.Field;
          Control := ADynControlEngineDB.CreateDBFieldControl(Field, AParentControl, AParentControl, '', ds);
          Control.Enabled := Not IsFieldReadOnly (Field.FieldName);
          if FieldDefaultWidth > 0 then
            Control.Width := FieldDefaultWidth
          else
          begin
            if UseFieldSizeForWidth then
              if Field.Size > 0 then
                Control.Width :=
                  TAccessCustomControl(AParentControl).Canvas.TextWidth('X') * Field.Size
              else
            else
            if Field.DisplayWidth > 0 then
              Control.Width :=
                TAccessCustomControl(AParentControl).Canvas.TextWidth('X') * Field.DisplayWidth;
            if (FieldMaxWidth > 0) and (Control.Width > FieldMaxWidth) then
              Control.Width := FieldMaxWidth
            else
            if (FieldMinWidth > 0) and (Control.Width < FieldMinWidth) then
              Control.Width := FieldMinWidth;
          end;
          if UseParentColorForReadOnly then
            if (Assigned(ds.DataSet) and not ds.DataSet.CanModify) or Field.ReadOnly then
              if isPublishedProp(Control, 'ParentColor') then
                SetOrdProp(Control, 'ParentColor', Ord(True));
          LabelControl := ADynControlEngineDB.DynControlEngine.CreateLabelControlPanel(AParentControl, AParentControl,
            '', '&' + Column.Title.Caption, Control, True, 0);
          if FieldWidthStep > 0 then
            if (LabelControl.Width mod FieldWidthStep) <> 0 then
              LabelControl.Width := ((LabelControl.Width div FieldWidthStep) + 1) * FieldWidthStep;
        end;
      end;
  end;
end;

function TJvDatabaseActionDBGridEngine.GetSelectedField: TField;
begin
  if Assigned(CustomDBGrid) then
    Result := CustomDBGrid.SelectedField
  else
    Result := nil;
end;

function TJvDatabaseActionDBGridEngine.SelectedRowsCount: Integer;
begin
  if Assigned(CustomDBGrid) then
    Result := TAccessCustomDBGrid(CustomDBGrid).SelectedRows.Count
  else
    Result := 0;
end;

procedure TJvDatabaseActionDBGridEngine.SetDatacomponent(const Value :
    TComponent);
begin
  inherited SetDatacomponent (Value);
  FCustomDbGrid := GetCustomDBGrid (Value);
end;

function TJvDatabaseActionDBGridEngine.Supports(ADataComponent: TComponent): boolean;
begin
  Result := Assigned(ADataComponent) and (ADataComponent is TCustomDBGrid);
end;

procedure TJvDatabaseActionDBGridEngine.ShowSingleRecordWindow(AOptions:
    TJvShowSingleRecordWindowOptions);
var
  Dialog: TJvDynControlDataSourceEditDialog;
begin
  Dialog := TJvDynControlDataSourceEditDialog.Create;
  try
    AOptions.SetOptionsToDialog(Dialog);
    if Dialog.DynControlEngineDB.SupportsDataComponent(DataComponent) then
      Dialog.DataComponent := DataComponent
    else
      Dialog.DataComponent := DataSource;
    Dialog.OnCreateDataControlsEvent := OnCreateDataControls;
    Dialog.ShowDialog;
  finally
    Dialog.Free;
  end;
end;

//=== { TJvDatabaseActionDevExpCxGridEngine } ================================

{$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}

constructor TJvDatabaseActionDevExpCxGridEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGridView := nil;
end;

function TJvDatabaseActionDevExpCxGridEngine.GetGridView(ADataComponent:
    TComponent): TcxCustomGridTableView;
begin
  if Assigned(ADataComponent) then
    if ADataComponent is TcxGrid then
      if TcxGrid(ADataComponent).FocusedView is TcxCustomGridTableView then
        Result := TcxCustomGridTableView(TcxGrid(ADataComponent).FocusedView)
      else
        Result := nil
    else
    if ADataComponent is TcxCustomGridTableView then
      Result := TcxCustomGridTableView(ADataComponent)
    else
      Result := nil
  else
    Result := nil;
end;

function TJvDatabaseActionDevExpCxGridEngine.GetDataSource(ADataComponent:
    TComponent): TDataSource;
begin
  if Assigned(ADataComponent) then
    if ADataComponent is TcxGrid then
      if (TcxGrid(ADataComponent).FocusedView is TcxCustomGridTableView) and
        (TcxCustomGridTableView(TcxGrid(ADataComponent).FocusedView).DataController is TcxGridDBDataController) then
        Result := TcxGridDBDataController(TcxCustomGridTableView(
          TcxGrid(ADataComponent).FocusedView).DataController).DataSource
      else
        Result := nil
    else
    if ADataComponent is TcxCustomGridTableView then
      if TcxCustomGridTableView(ADataComponent).DataController is TcxGridDBDataController then
        Result := TcxGridDBDataController(TcxCustomGridTableView(ADataComponent).DataController).DataSource
      else
        Result := nil
    else
      Result := inherited GetDataSource(ADataComponent)
  else
    Result := nil;
end;

function TJvDatabaseActionDevExpCxGridEngine.Supports(ADataComponent: TComponent): boolean;
begin
  Result := Assigned(GetGridView(ADataComponent));
end;

function TJvDatabaseActionDevExpCxGridEngine.Bof: boolean;
begin
  if Assigned(GridView) then
    Result := GridView.DataController.FocusedRowIndex = 0
  else
    Result := inherited Bof;
end;

function TJvDatabaseActionDevExpCxGridEngine.RecNo: integer;
begin
  if Assigned(GridView) then
    Result := GridView.DataController.FocusedRowIndex + 1
  else
    Result := inherited RecNo;
end;

function TJvDatabaseActionDevExpCxGridEngine.RecordCount: integer;
begin
  if Assigned(GridView) then
    Result := GridView.DataController.RecordCount
  else
    Result := inherited RecordCount;
end;


function TJvDatabaseActionDevExpCxGridEngine.CanInsert: boolean;
begin
  if Assigned(GridView) then
    Result := GridView.OptionsData.Inserting and inherited CanInsert
  else
    Result := inherited CanInsert;
end;

function TJvDatabaseActionDevExpCxGridEngine.CanUpdate: boolean;
begin
  if Assigned(GridView) then
    Result := GridView.OptionsData.Editing and inherited CanUpdate
  else
    Result := inherited CanUpdate;
end;

function TJvDatabaseActionDevExpCxGridEngine.CanDelete: boolean;
begin
  if Assigned(GridView) then
    Result := GridView.OptionsData.Deleting and inherited CanDelete
  else
    Result := inherited CanDelete;
end;

procedure TJvDatabaseActionDevExpCxGridEngine.First;
begin
  if Assigned(GridView) then
    GridView.DataController.GotoFirst
  else
    inherited First;
end;

procedure TJvDatabaseActionDevExpCxGridEngine.GotoSelectedRow(const
    ASelectedRow: Integer);
begin
  if Assigned(GridView) then
    GridView.Controller.FocusedRecordIndex  := GridView.Controller.SelectedRecords[ASelectedRow].RecordIndex;
end;

procedure TJvDatabaseActionDevExpCxGridEngine.Last;
begin
  if Assigned(GridView) then
    GridView.DataController.GotoLast
  else
    inherited Last;
end;

procedure TJvDatabaseActionDevExpCxGridEngine.MoveBy(Distance : Integer);
begin
  if Assigned(GridView) then
    GridView.DataController.MoveBy(Distance)
  else
    inherited MoveBy(Distance);
end;

function TJvDatabaseActionDevExpCxGridEngine.SelectedRowsCount: Integer;
begin
  if Assigned(GridView) then
    Result := GridView.DataController.GetSelectedCount
  else
    Result := 0;
end;

procedure TJvDatabaseActionDevExpCxGridEngine.SetDatacomponent(const Value :
    TComponent);
begin
  inherited SetDatacomponent (Value);
  FGridView := GetGridView(Value);
end;

{$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}

//=== { TJvDatabaseBaseAction } ==============================================

constructor TJvDatabaseBaseAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if Assigned(AOwner) and (AOwner is TJvDatabaseActionList) then
    DataComponent := TJvDatabaseActionList(AOwner).DataComponent;
end;

function TJvDatabaseBaseAction.GetDataSet: TDataSet;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.DataSet
  else
    Result := nil;
end;

function TJvDatabaseBaseAction.GetDataSource: TDataSource;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.DataSource
  else
    Result := nil;
end;

procedure TJvDatabaseBaseAction.SetDataComponent(Value: TComponent);
begin
  FDataComponent := Value;
  if FDataComponent <> nil then
    FDataComponent.FreeNotification(Self);
  if Assigned(IntRegisteredActionEngineList) then
  begin
    FDataEngine := IntRegisteredActionEngineList.GetEngine(FDataComponent);
    if Assigned(FDataEngine) then
      FDataEngine.Datacomponent := FDatacomponent;
  end
  else
    FDataEngine := nil;
  if Assigned(OnChangeDataComponent) then
    OnChangeDataComponent (Value);
end;

procedure TJvDatabaseBaseAction.SetEnabled(Value: boolean);
begin
  if Enabled <> Value then
    Enabled := Value;
end;

function TJvDatabaseBaseAction.EngineIsActive: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.IsActive
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineHasData: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.HasData
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineFieldCount: integer;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.FieldCount
  else
    Result := -1;
end;

function TJvDatabaseBaseAction.EngineRecordCount: integer;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.RecordCount
  else
    Result := -1;
end;

function TJvDatabaseBaseAction.EngineRecNo: integer;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.RecNo
  else
    Result := -1;
end;

function TJvDatabaseBaseAction.EngineCanInsert: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.CanInsert
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineCanUpdate: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.CanUpdate
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineCanDelete: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.CanDelete
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineEof: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.EOF
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineBof: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.Bof
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineControlsDisabled: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.ControlsDisabled
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineEditModeActive: boolean;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.EditModeActive
  else
    Result := False;
end;

function TJvDatabaseBaseAction.EngineSelectedRowsCount: integer;
begin
  if Assigned(DataEngine) then
    Result := DataEngine.SelectedRowsCount
  else
    Result := -1;
end;

function TJvDatabaseBaseAction.HandlesTarget(Target: TObject): boolean;
begin
  //  Result := inherited HandlesTarget(Target);
  Result := Assigned(DataEngine);
end;

procedure TJvDatabaseBaseAction.UpdateTarget(Target: TObject);
begin
  if Assigned(DataSet) and not EngineControlsDisabled then
    SetEnabled(True)
  else
    SetEnabled(False);
end;

procedure TJvDatabaseBaseAction.ExecuteTarget(Target: TObject);
begin
  if Assigned(FOnExecute) then
    FOnExecute(Self, DataEngine, DataComponent)
  else
  if Assigned(FOnExecuteDataSource) then
    FOnExecuteDataSource(Self, DataSource)
  else
    inherited ExecuteTarget(Target);
end;

procedure TJvDatabaseBaseAction.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataComponent) then
    DataComponent := nil;
end;

//=== { TJvDatabaseSimpleAction } ============================================

constructor TJvDatabaseSimpleAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsActive  := True;
  FHasData   := True;
  FCanInsert := False;
  FCanUpdate := False;
  FCanDelete := False;
  FEditModeActive := False;
  FManualEnabled := True;
end;

procedure TJvDatabaseSimpleAction.SetManualEnabled(const Value: Boolean);
begin
  FManualEnabled := Value;
  UpdateTarget(Self);
end;

procedure TJvDatabaseSimpleAction.UpdateTarget(Target: TObject);
var
  Res: boolean;
begin
  if Assigned(DataSet) and not EngineControlsDisabled then
  begin
    Res := ManualEnabled;
    if IsActive then
      Res := Res and EngineIsActive;
    if HasData then
      Res := Res and EngineHasData;
    if CanInsert then
      Res := Res and EngineCanInsert;
    if CanUpdate then
      Res := Res and EngineCanUpdate;
    if CanDelete then
      Res := Res and EngineCanDelete;
    if EditModeActive then
      Res := Res and EngineEditModeActive;
    SetEnabled(Res);
  end
  else
    SetEnabled(False);
end;

//=== { TJvDatabaseBaseActiveAction } ========================================

procedure TJvDatabaseBaseActiveAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive);
end;

//=== { TJvDatabaseBaseEditAction } ==========================================

procedure TJvDatabaseBaseEditAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and
    (EngineCanInsert or EngineCanUpdate or EngineCanDelete));
end;

//=== { TJvDatabaseFirstAction } =============================================

procedure TJvDatabaseFirstAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataEngine) and not EngineControlsDisabled and EngineIsActive and not EngineBof);
end;

procedure TJvDatabaseFirstAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataEngine.First;
end;

//=== { TJvDatabaseLastAction } ==============================================

procedure TJvDatabaseLastAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataEngine) and not EngineControlsDisabled and EngineIsActive and not EngineEof);
end;

procedure TJvDatabaseLastAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataEngine.Last;
end;

//=== { TJvDatabasePriorAction } =============================================

procedure TJvDatabasePriorAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataEngine) and not EngineControlsDisabled and EngineIsActive and not EngineBof);
end;

procedure TJvDatabasePriorAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataEngine.MoveBy(-1);
end;

//=== { TJvDatabaseNextAction } ==============================================

procedure TJvDatabaseNextAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataEngine) and not EngineControlsDisabled and EngineIsActive and not EngineEof);
end;

procedure TJvDatabaseNextAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataEngine.MoveBy(1);
end;

//=== { TJvDatabasePriorBlockAction } ========================================

constructor TJvDatabasePriorBlockAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBlockSize := 50;
end;

procedure TJvDatabasePriorBlockAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataEngine) and not EngineControlsDisabled and EngineIsActive and not EngineBof);
end;

procedure TJvDatabasePriorBlockAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  with DataEngine do
    try
      DisableControls;
      MoveBy(-BlockSize);
    finally
      EnableControls;
    end;
end;

//=== { TJvDatabaseNextBlockAction } =========================================

constructor TJvDatabaseNextBlockAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBlockSize := 50;
end;

procedure TJvDatabaseNextBlockAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataEngine) and not EngineControlsDisabled and EngineIsActive and not EngineEof);
end;

procedure TJvDatabaseNextBlockAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  with DataEngine do
    try
      DisableControls;
      MoveBy(BlockSize);
    finally
      EnableControls;
    end;
end;

//=== { TJvDatabaseRefreshAction } ===========================================

constructor TJvDatabaseRefreshAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRefreshLastPosition := True;
  FRefreshAsOpenClose  := False;
end;

procedure TJvDatabaseRefreshAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  Refresh;
end;

procedure TJvDatabaseRefreshAction.Refresh;
var
  MyBookmark: TBookmark;
begin
  with DataEngine.DataSet do
  begin
    MyBookmark := nil;
    if RefreshLastPosition then
      MyBookmark := GetBookmark;

    try
      if RefreshAsOpenClose then
      begin
        Close;
        Open;
      end
      else
        Refresh;

      if RefreshLastPosition then
        if Active then
          if Assigned(MyBookmark) then
            if BookmarkValid(MyBookmark) then
              try
                GotoBookmark(MyBookmark);
              except
              end;
    finally
      if RefreshLastPosition then
        FreeBookmark(MyBookmark);
    end;
  end;
end;

//=== { TJvDatabasePositionAction } ==========================================

procedure TJvDatabasePositionAction.UpdateTarget(Target: TObject);
const
  cFormat = ' %3d / %3d ';
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and EngineHasData);
  try
    if not EngineIsActive then
      SetCaption (Format(cFormat, [0, 0]))
    else
    if EngineRecordCount = 0 then
      SetCaption (Format(cFormat, [0, 0]))
    else
      SetCaption (Format(cFormat, [EngineRecNo, EngineRecordCount]));
  except
    SetCaption (Format(cFormat, [0, 0]));
  end;
end;

procedure TJvDatabasePositionAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  ShowPositionDialog;
end;

procedure TJvDatabasePositionAction.SetCaption(Value: string);
begin
  if Value <> Caption then
    Caption := Value;
end;

procedure TJvDatabasePositionAction.ShowPositionDialog;
const
  cCurrentPosition = 'CurrentPosition';
  cNewPosition = 'NewPosition';
  cKind = 'Kind';
var
  ParameterList: TJvParameterList;
  Parameter: TJvBaseParameter;
  S:    string;
  Kind: integer;
begin
  if not Assigned(DataSet) then
    Exit;
  ParameterList := TJvParameterList.Create(Self);
  try
    Parameter := TJvBaseParameter(TJvEditParameter.Create(ParameterList));
    with TJvEditParameter(Parameter) do
    begin
      SearchName := cCurrentPosition;
      ReadOnly   := True;
      Caption    := RsDBPosCurrentPosition;
      AsString   := IntToStr(EngineRecNo + 1) + ' / ' + IntToStr(EngineRecordCount);
      Width      := 150;
      LabelWidth := 80;
      Enabled    := False;
    end;
    ParameterList.AddParameter(Parameter);
    Parameter := TJvBaseParameter(TJvEditParameter.Create(ParameterList));
    with TJvEditParameter(Parameter) do
    begin
      Caption    := RsDBPosNewPosition;
      SearchName := cNewPosition;
      // EditMask := '999999999;0;_';
      Width      := 150;
      LabelWidth := 80;
    end;
    ParameterList.AddParameter(Parameter);
    Parameter := TJvBaseParameter(TJvRadioGroupParameter.Create(ParameterList));
    with TJvRadioGroupParameter(Parameter) do
    begin
      Caption    := RsDBPosMovementType;
      SearchName := cKind;
      Width      := 305;
      Height     := 54;
      Columns    := 2;
      ItemList.Add(RsDBPosAbsolute);
      ItemList.Add(RsDBPosForward);
      ItemList.Add(RsDBPosBackward);
      ItemList.Add(RsDBPosPercental);
      ItemIndex := 0;
    end;
    ParameterList.AddParameter(Parameter);
    ParameterList.ArrangeSettings.WrapControls := True;
    ParameterList.ArrangeSettings.MaxWidth := 350;
    ParameterList.Messages.Caption := RsDBPosDialogCaption;
    if ParameterList.ShowParameterDialog then
    begin
      S := ParameterList.ParameterByName(cNewPosition).AsString;
      if S = '' then
        Exit;
      Kind := TJvRadioGroupParameter(ParameterList.ParameterByName(cKind)).ItemIndex;
      DataSet.DisableControls;
      try
        case Kind of
          0:
          begin
            DataSet.First;
            DataSet.MoveBy(StrToInt(S) - 1);
          end;
          1:
            DataSet.MoveBy(StrToInt(S));
          2:
            DataSet.MoveBy(StrToInt(S) * -1);
          3:
          begin
            DataSet.First;
            DataSet.MoveBy(Round((EngineRecordCount / 100.0) * StrToInt(S)) - 1);
          end;
        end;
      finally
        DataSet.EnableControls;
      end;
    end;
  finally
    ParameterList.Free;
  end;
end;

//=== { TJvDatabaseInsertAction } ============================================

procedure TJvDatabaseInsertAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and
    EngineIsActive and EngineCanInsert and not EngineEditModeActive);
end;

procedure TJvDatabaseInsertAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Insert;
end;

//=== { TJvDatabaseCopyAction } ==============================================

procedure TJvDatabaseCopyAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and
    EngineCanInsert and EngineHasData and not EngineEditModeActive);
end;

procedure TJvDatabaseCopyAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  CopyRecord;
end;

procedure TJvDatabaseCopyAction.CopyRecord;
var
  Values: array of variant;
  I:      integer;
  Value:  variant;
  Allowed: boolean;
begin
  with DataSet do
  begin
    if not Active then
      Exit;
    if State in [dsInsert, dsEdit] then
      Post;
    if State <> dsBrowse then
      Exit;
    Allowed := True;
  end;
  if Assigned(FBeforeCopyRecord) then
    FBeforeCopyRecord(DataSet, Allowed);
  with DataSet do
  begin
    // (rom) this suppresses AfterCopyRecord. Is that desired?
    if not Allowed then
      Exit;
    SetLength(Values, FieldCount);
    for I := 0 to FieldCount - 1 do
      Values[I] := Fields[I].AsVariant;
    Insert;
    if Assigned(FOnCopyRecord) then
      for I := 0 to FieldCount - 1 do
      begin
        Value := Values[I];
        FOnCopyRecord(Fields[I], Value);
      end
    else
      for I := 0 to FieldCount - 1 do
        Fields[I].AsVariant := Values[I];
  end;
  if Assigned(FAfterCopyRecord) then
    FAfterCopyRecord(DataSet);
end;

//=== { TJvDatabaseEditAction } ==============================================

procedure TJvDatabaseEditAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and
    EngineCanUpdate and EngineHasData and not EngineEditModeActive);
end;

procedure TJvDatabaseEditAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Edit;
end;

//=== { TJvDatabaseDeleteAction } ============================================

procedure TJvDatabaseDeleteAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and
    EngineCanDelete and EngineHasData and not EngineEditModeActive);
end;

procedure TJvDatabaseDeleteAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Delete;
end;

//=== { TJvDatabasePostAction } ==============================================

procedure TJvDatabasePostAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and EngineEditModeActive);
end;

procedure TJvDatabasePostAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Post;
end;

//=== { TJvDatabaseCancelAction } ============================================

procedure TJvDatabaseCancelAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and EngineIsActive and EngineEditModeActive);
end;

procedure TJvDatabaseCancelAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Cancel;
end;

//=== { TJvDatabaseSingleRecordWindowAction } ================================

constructor TJvDatabaseSingleRecordWindowAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := TJvShowSingleRecordWindowOptions.Create;
end;

destructor TJvDatabaseSingleRecordWindowAction.Destroy;
begin
  FOptions.Free;
  inherited Destroy;
end;

procedure TJvDatabaseSingleRecordWindowAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  ShowSingleRecordWindow
end;

procedure TJvDatabaseSingleRecordWindowAction.ShowSingleRecordWindow;
begin
  DataEngine.ShowSingleRecordWindow(Options);
end;

//=== { TJvDatabaseOpenAction } ==============================================

procedure TJvDatabaseOpenAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineIsActive);
end;

procedure TJvDatabaseOpenAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Open;
end;

//=== { TJvDatabaseCloseAction } =============================================

procedure TJvDatabaseCloseAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and EngineIsActive and not EngineEditModeActive);
end;

procedure TJvDatabaseCloseAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  DataSet.Close;
end;

{$IFDEF USE_3RDPARTY_SMEXPORT}

//=== { TJvDatabaseSMExportOptions } =========================================

constructor TJvDatabaseSMExportOptions.Create;
var
  Fmt:    TTableTypeExport;
  Option: TSMOption;
begin
  inherited Create;
  FFormats := [];
  for Fmt := Low(Fmt) to High(Fmt) do
    FFormats := FFormats + [Fmt];
  FOptions := [];
  for Option := Low(Option) to High(Option) do
    FOptions := FOptions + [Option];
  //  FDataFormats := TSMEDataFormats.Create;
end;

destructor TJvDatabaseSMExportOptions.Destroy;
begin
  //  FreeAndNil(FDataFormats);
  inherited Destroy;
end;

procedure TJvDatabaseSMExportOptions.SMEWizardDlgGetCellParams(Sender: TObject; Field: TField;
  var Text: string; AFont: TFont; var Alignment: TAlignment; var Background: TColor; var CellType: TCellType);
const
  SToDateFormatLong = 'TO_DATE(''%s'', ''DD.MM.YYYY HH24:MI:SS'')';
  SToDateFormatShort = 'TO_DATE(''%s'', ''DD.MM.YYYY'')';
  SFormatLong = 'dd.mm.yyyy hh:nn:ss';
  SFormatShort = 'dd.mm.yyyy';
  SNull = 'NULL';
var
  DT: TDateTime;
begin
  if Sender is TSMExportToSQL then
    if Assigned(Field) then
    begin
      if Field.IsNull or (Field.AsString = '') then
      begin
        Text     := SNull;
        CellType := ctBlank;
      end
      else
      if Field.DataType in [ftFloat, ftBCD, ftCurrency] then
        Text := AnsiReplaceStr(Text, ',', '.')
      else
      if Field.DataType in [ftDate, ftDateTime] then
      begin
        DT := Field.AsDateTime;
        if DT <= 0 then
          Text := SNull
        else
        if DT = Trunc(DT) then
          Text := Format(SToDateFormatShort, [FormatDateTime(SFormatShort, DT)])
        else
          Text := Format(StoDateFormatLong, [FormatDateTime(SFormatLong, DT)]);
        CellType := ctBlank;
      end
      else
      if Field.DataType in [ftString, ftWideString] then
        Text := '''' + AnsiReplaceStr(Text, '''', '''''') + '''';
    end
    else
    if Text = '' then
    begin
      Text     := SNull;
      CellType := ctBlank;
    end
    else
    if CellType in [ctDouble, ctCurrency] then
      Text := AnsiReplaceStr(Text, ',', '.')
    else
    if CellType in [ctDateTime, ctDate, ctTime] then
    begin
      DT := StrToDate(Text);
      if DT <= 0 then
        Text := SNull
      else
      if DT = Trunc(DT) then
        Text := Format(SToDateFormatShort, [FormatDateTime(SFormatShort, DT)])
      else
        Text := Format(StoDateFormatLong, [FormatDateTime(SFormatLong, DT)]);
      CellType := ctBlank;
    end
    else
    if CellType in [ctString] then
      Text := '''' + AnsiReplaceStr(Text, '''', '''''') + '''';
end;

procedure TJvDatabaseSMExportOptions.SMEWizardDlgOnBeforeExecute(Sender: TObject);
begin
  if Sender is TSMExportToSQL then
    TSMExportToSQL(Sender).SQLQuote := #0;
end;

//=== { TJvDatabaseSMExportAction } ==========================================

constructor TJvDatabaseSMExportAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := TJvDatabaseSMExportOptions.Create;
end;

destructor TJvDatabaseSMExportAction.Destroy;
begin
  FOptions.Free;
  inherited Destroy;
end;

procedure TJvDatabaseSMExportAction.ExecuteTarget(Target: TObject);
begin
  inherited ExecuteTarget(Target);
  ExportData;
end;

procedure TJvDatabaseSMExportAction.ExportData;
const
  cLastExport = '\Last Export.SME';
var
  SMEWizardDlg: TSMEWizardDlg;
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  SMEEngineCx:  TSMEcxCustomGridTableViewDataEngine;
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
begin
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  SMEEngineCx  := nil;
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  SMEWizardDlg := TSMEWizardDlg.Create(Self);
  try
    SMEWizardDlg.ColumnSource := csDataSet;
    SMEWizardDlg.OnGetCellParams := Options.SMEWizardDlgGetCellParams;
    SMEWizardDlg.OnBeforeExecute := Options.SMEWizardDlgOnBeforeExecute;
    SMEWizardDlg.DataSet := DataSource.DataSet;
    SMEWizardDlg.Title   := Options.Title;
    SMEWizardDlg.KeyGenerator := Options.Title;
    SMEWizardDlg.WizardStyle := smewiz.wsWindows2000;
    SMEWizardDlg.SpecificationDir := Options.DefaultOptionsDirectory + '\';
    if DataComponent is TCustomDBGrid then
    begin
      SMEWizardDlg.DBGrid := TCustomControl(DataComponent);
      SMEWizardDlg.ColumnSource := csDBGrid;
    end
    {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
    else
    if (DataComponent is TcxGrid) and (TcxGrid(DataComponent).FocusedView is TcxCustomGridTableView) then
    begin
      SMEEnginecx := TSMEcxCustomGridTableViewDataEngine.Create(Self);
      SMEEngineCx.cxCustomGridTableView := TcxCustomGridTableView(TcxGrid(DataComponent).FocusedView);
      SMEWizardDlg.DataEngine := SMEEngineCx;
      SMEWizardDlg.ColumnSource := csDataEngine;
    end
    else
    if DataComponent is TcxCustomGridTableView then
    begin
      SMEEnginecx := TSMEcxCustomGridTableViewDataEngine.Create(Self);
      SMEEngineCx.cxCustomGridTableView := TcxCustomGridTableView(DataComponent);
      SMEWizardDlg.DataEngine := SMEEngineCx;
      SMEWizardDlg.ColumnSource := csDataEngine;
    end
    {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
    else
    begin
      SMEWizardDlg.DataSet := DataSet;
      SMEWizardDlg.ColumnSource := csDataSet;
    end;

    SMEWizardDlg.Formats := Options.Formats;
    SMEWizardDlg.Options := Options.Options;
    SMEWizardDlg.HelpContext := Options.HelpContext;
    if FileExists(Options.DefaultOptionsDirectory + cLastExport) then
      SMEWizardDlg.LoadSpecification(Options.DefaultOptionsDirectory + cLastExport);
    SMEWizardDlg.Execute;
    SMEWizardDlg.SaveSpecification('Last Export', Options.DefaultOptionsDirectory + cLastExport, False);
  finally
    {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
    FreeAndNil(SMEEngineCx);
    {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
    FreeAndNil(SMEWizardDlg);
  end;
end;

{$ENDIF USE_3RDPARTY_SMEXPORT}

{$IFDEF USE_3RDPARTY_SMIMPORT}

//=== { TJvDatabaseSMImportOptions } =========================================

constructor TJvDatabaseSMImportOptions.Create;
var
  Fmt:    TTableTypeImport;
  Option: TSMIOption;
begin
  inherited Create;
  FFormats := [];
  for Fmt := Low(Fmt) to High(Fmt) do
    FFormats := FFormats + [Fmt];
  FOptions := [];
  for Option := Low(Option) to High(Option) do
    FOptions := FOptions + [Option];
end;

//=== { TJvDatabaseSMImportAction } ==========================================

constructor TJvDatabaseSMImportAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := TJvDatabaseSMImportOptions.Create;
end;

destructor TJvDatabaseSMImportAction.Destroy;
begin
  FOptions.Free;
  inherited Destroy;
end;

procedure TJvDatabaseSMImportAction.ExecuteTarget(Target: TObject);
begin
  inherited;
  ImportData;
end;

procedure TJvDatabaseSMImportAction.ImportData;
var
  SMIWizardDlg: TSMIWizardDlg;
begin
  SMIWizardDlg := TSMIWizardDlg.Create(Self);
  try
    //    SMIWizardDlg.OnGetSpecifications := Options.SMIWizardDlgGetSpecifications;
    SMIWizardDlg.SpecificationDir := Options.DefaultOptionsDirectory + '\';
    SMIWizardDlg.DataSet := DataSource.DataSet;
    SMIWizardDlg.Title   := Options.Title;
    SMIWizardDlg.Formats := Options.Formats;
    SMIWizardDlg.HelpContext := Options.HelpContext;
    SMIWizardDlg.WizardStyle := Options.WizardStyle;
    SMIWizardDlg.Options := Options.Options;
    //    IF FileExists (Options.DefaultOptionsDirectory+'\Last Import.SMI') THEN
    //      SMIWizardDlg.LoadSpecification(Options.DefaultOptionsDirectory+'\Last Import.SMI');
    SMIWizardDlg.Execute;
    SMIWizardDlg.SaveSpecification('Last Import', Options.DefaultOptionsDirectory + '\Last Import.SMI', False);
  finally
    FreeAndNil(SMIWizardDlg);
  end;
end;

{$ENDIF USE_3RDPARTY_SMIMPORT}

//=== { TJvDatabaseActionEngineList } ========================================

destructor TJvDatabaseActionEngineList.Destroy;
var
  I: integer;
begin
  for I := Count - 1 downto 0 do
  begin
    TJvDatabaseActionBaseEngine(Items[I]).Free;
    Items[I] := nil;
    Delete(I);
  end;
  inherited Destroy;
end;

procedure TJvDatabaseActionEngineList.RegisterEngine(AEngineClass: TJvDatabaseActionBaseEngineClass);
begin
  Add(AEngineClass.Create(nil));
end;

function TJvDatabaseActionEngineList.GetEngine(AComponent: TComponent): TJvDatabaseActionBaseEngine;
var
  Ind: integer;
begin
  Result := nil;
  for Ind := 0 to Count - 1 do
    if TJvDatabaseActionBaseEngine(Items[Ind]).Supports(AComponent) then
    begin
      Result := TJvDatabaseActionBaseEngine(Items[Ind]);
      Break;
    end;
end;

function TJvDatabaseActionEngineList.Supports(AComponent: TComponent): boolean;
begin
  Result := Assigned(GetEngine(AComponent));
end;

//=== Global =================================================================

function RegisteredDatabaseActionEngineList: TJvDatabaseActionEngineList;
begin
  Result := IntRegisteredActionEngineList;
end;

procedure RegisterActionEngine(AEngineClass: TJvDatabaseActionBaseEngineClass);
begin
  if Assigned(IntRegisteredActionEngineList) then
    IntRegisteredActionEngineList.RegisterEngine(AEngineClass);
end;

procedure CreateActionEngineList;
begin
  IntRegisteredActionEngineList := TJvDatabaseActionEngineList.Create;
end;

procedure DestroyActionEngineList;
begin
  IntRegisteredActionEngineList.Free;
  IntRegisteredActionEngineList := nil;
end;

procedure ActionInit;
begin
  CreateActionEngineList;
  RegisterActionEngine(TJvDatabaseActionBaseEngine);
  RegisterActionEngine(TJvDatabaseActionDBGridEngine);
  {$IFDEF USE_3RDPARTY_DEVEXPRESS_CXGRID}
  RegisterActionEngine(TJvDatabaseActionDevExpCxGridEngine);
  {$ENDIF USE_3RDPARTY_DEVEXPRESS_CXGRID}
end;

//=== { TJvDatabaseModifyAllAction } ============================================

constructor TJvDatabaseModifyAllAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabledOnlyIfSelectedRows := True;
end;

procedure TJvDatabaseModifyAllAction.ExecuteTarget(Target: TObject);
begin
  ModifyAll;
end;

procedure TJvDatabaseModifyAllAction.ModifyAll;
var
  JvParameterList :TJvParameterList;
  Parameter : TJvBaseParameter;
  i: Integer;
  Field:TField;
  FieldName : String;
  ChangeTo : String;
  ClearField : Boolean;
  OnlyIfNull : Boolean;
begin
  if not Assigned(DataEngine) then
    Exit;
  JvParameterList := TJvParameterList.Create(self);
  try
    JvParameterList.Messages.Caption := 'Modify All Records';
    JvParameterList.Messages.OkButton := 'Modify';
    Parameter := TJvBaseParameter(TJvComboBoxParameter.Create(JvParameterList));
    with TJvComboBoxParameter(Parameter) do
    begin
      LabelArrangeMode := lamAbove;
      SearchName := 'ModifyField';
      Caption := 'Modify Field';
      Width := 330;
      for i := 0 to EngineFieldCount - 1 do
      begin
        Field := DataEngine.FieldById(i);
        if Assigned(Field) then
          if not DataEngine.IsFieldReadOnly (Field.FieldName)
            and  DataEngine.IsFieldVisible (Field.FieldName) then
            ItemList.Add(Field.FieldName);
        if Assigned(DataEngine.SelectedField) then
          ItemIndex := ItemList.IndexOf(DataEngine.SelectedField.FieldName);
        if (ItemIndex < 0) or (ItemIndex >= ItemList.Count) then
          ItemIndex:= 0;
      end;
    end;
    JvParameterList.AddParameter(Parameter);
    Parameter := TJvCheckBoxParameter.Create(JvParameterList);
    with TJvCheckBoxParameter(Parameter) do
    begin
      SearchName := 'ClearFieldValues';
      Caption := 'Clear Field Values';
      Width := 150;
    end;
    JvParameterList.AddParameter(Parameter);
    Parameter := TJvEditParameter.Create(JvParameterList);
    with TJvEditParameter(Parameter) do
    begin
      SearchName := 'ChangeTo';
      Caption := 'Change To';
      Width := 330;
      LabelArrangeMode := lamAbove;
      DisableReasons.AddReason ('ClearFieldValues', True);
    end;
    JvParameterList.AddParameter(Parameter);
    Parameter := TJvCheckBoxParameter.Create(JvParameterList);
    with TJvCheckBoxParameter(Parameter) do
    begin
      SearchName := 'OnlyIfNull';
      Caption := 'Only If Null';
      Width := 150;
      DisableReasons.AddReason ('ClearFieldValues', True);
    end;
    JvParameterList.AddParameter(Parameter);
    JvParameterList.MaxWidth := 360;
    if JvParameterList.ShowParameterDialog then
    begin
      FieldName  := JvParameterList.ParameterByName('ModifyField').AsString;
      ClearField := JvParameterList.ParameterByName('ClearFieldValues').AsBoolean;
      OnlyIfNull := JvParameterList.ParameterByName('OnlyIfNull').AsBoolean;
      ChangeTo := JvParameterList.ParameterByName('ChangeTo').AsString;
      Field := DataEngine.FieldByName(FieldName);
      if Assigned(Field) then
      try
        DataEngine.DisableControls;
        for I := 0 to Dataengine.SelectedRowsCount - 1 do
        begin
          DataEngine.GotoSelectedRow(i);
          try
            if (ClearField and not Field.IsNull) or
              not ( OnlyIfNull and not Field.IsNull) then
            begin
              DataEngine.Dataset.Edit;
              if ClearField then
                Field.Clear
              else
                Field.AsString := ChangeTo;
              if Assigned(DataEngine.Dataset) then
                DataEngine.Dataset.Post;
            end;
          except
            on e:exception do
            begin
              DataEngine.Dataset.Cancel;
              JvDSADialogs.MessageDlg(e.Message, mtError, [mbOK], 0);
            end;
          end;
        end;
      finally
        DataEngine.EnableControls;
      end;
    end;
  finally
    FreeAndNil (JvParameterList);
  end;
end;

procedure TJvDatabaseModifyAllAction.UpdateTarget(Target: TObject);
begin
  SetEnabled(Assigned(DataSet) and not EngineControlsDisabled and
    EngineIsActive and EngineCanUpdate and not EngineEditModeActive and
    (not EnabledOnlyIfSelectedRows or (EngineSelectedRowsCount > 1)));
end;

initialization
  {$IFDEF UNITVERSIONING}
  RegisterUnitVersion(HInstance, UnitVersioning);
  {$ENDIF UNITVERSIONING}
  ActionInit;

finalization
  DestroyActionEngineList;
  {$IFDEF UNITVERSIONING}
  UnregisterUnitVersion(HInstance);
  {$ENDIF UNITVERSIONING}

end.

