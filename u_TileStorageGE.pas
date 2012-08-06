{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2012, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.ru                                                           *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit u_TileStorageGE;

interface

uses
  Windows,
  SysUtils,
  Classes,
  i_BinaryData,
  t_CommonTypes,
  t_RangeFillingMap,
  t_DLLCache,
  i_SimpleTileStorageConfig,
  u_MapVersionFactoryGE,
  i_ContentTypeInfo,
  i_MapVersionConfig,
  i_MapVersionInfo,
  i_TileInfoBasic,
  i_ContentTypeManager,
  u_MapTypeCacheConfig,
  u_GlobalCahceConfig,
  u_TileStorageAbstract;

type
  TTileStorageDLL = class(TTileStorageAbstract)
  protected
    FCacheConfig: TMapTypeCacheConfigDLL;
    FMainContentType: IContentTypeInfoBasic;
    FTileNotExistsTileInfo: ITileInfoBasic;
    // access
    FDLLSync: IReadWriteSync;
    FDLLHandle: THandle;
    FDLLCacheHandle: TDLLCacheHandle;
    // routines
    FDLLCache_EnumTileVersions: Pointer;
    FDLLCache_QueryTile: Pointer;
    FDLLCache_ConvertImage: Pointer;
    FDLLCache_QueryFillingMap: Pointer;
    // cached values
    FCachedNameInCache: AnsiString;
  protected
    // Lib routines
    function InternalLib_CleanupProc: Boolean; virtual;
    function InternalLib_Initialize: Boolean; virtual;
    function InternalLib_CheckInitialized: Boolean; virtual;
    function InternalLib_Unload: Boolean; virtual;
    function InternalLib_NotifyStateChanged(const AEnabled: Boolean): Boolean;
    function InternalLib_SetPath(const APath: PAnsiChar): Boolean;
    function InternalLib_GetTileVersions(const AEnumInfo: PEnumTileVersionsInfo): Boolean;
    function InternalLib_QueryTile(const ATileInfo: PQueryTileInfo): Boolean;
    function InternalLib_ConvertImage(
      const AConvertImage_Context: Pointer;
      const ABuffer: Pointer;
      const ASize: Cardinal
    ): Boolean;
  protected
    procedure DoOnMapSettingsEdit(Sender: TObject);

    function DoOnRangeFillingMap(
      Sender: TObject;
      const ASourceTilesRect: PRect;
      const AVersionInfo: IMapVersionInfo;
      const ARangeFillingMapInfo: PRangeFillingMapInfo
    ): Boolean;

    function QueryTileInternal(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo;
      AStream: TMemoryStream;
      out ATileInfo: ITileInfoBasic
    ): Boolean;
  public
    constructor Create(
      const AConfig: ISimpleTileStorageConfig;
      const AContentTypeManager: IContentTypeManager
    );
    destructor Destroy; override;

    // auxillary tile storage routines
    function GetMainContentType: IContentTypeInfoBasic; override;
    function GetAllowDifferentContentTypes: Boolean; override;
    function GetCacheConfig: TMapTypeCacheConfigAbstract; override;

    // common tile storage interface
    function GetTileInfo(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ): ITileInfoBasic; override;

    function GetTileRectInfo(
      const ARect: TRect;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ): ITileRectInfo; override;

    function LoadTile(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo;
      out ATileInfo: ITileInfoBasic
    ): IBinaryData; override;

    function GetTileFileName(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ): string; override;

    function DeleteTile(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ): Boolean; override;

    function DeleteTNE(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ): Boolean; override;

    procedure SaveTile(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo;
      const AData: IBinaryData
    ); override;

    procedure SaveTNE(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ); override;

    function GetListOfTileVersions(
      const AXY: TPoint;
      const AZoom: byte;
      const AVersionInfo: IMapVersionInfo
    ): IMapVersionListStatic; override;
  end;

  TTileStorageGE = class(TTileStorageDLL)
  protected
    function InternalLib_Initialize: Boolean; override;
    function InternalLib_CheckInitialized: Boolean; override;
  public
    constructor Create(
      const AConfig: ISimpleTileStorageConfig;
      AGlobalCacheConfig: TGlobalCahceConfig;
      const AContentTypeManager: IContentTypeManager
    );

    function GetRangeFillingMapItemSize: SmallInt; override;
  end;

  TTileStorageGC = class(TTileStorageDLL)
  protected
    function InternalLib_Initialize: Boolean; override;
    function InternalLib_CheckInitialized: Boolean; override;
  public
    constructor Create(
      const AConfig: ISimpleTileStorageConfig;
      AGlobalCacheConfig: TGlobalCahceConfig;
      const AContentTypeManager: IContentTypeManager
    );

    function GetRangeFillingMapItemSize: SmallInt; override;
  end;

implementation

uses
  u_BinaryDataByMemStream,
  u_MapVersionListStatic,
  u_AvailPicsNMC,
  u_Synchronizer,
  u_TileInfoBasic,
  u_TileStorageTypeAbilities;

function DLLCache_ConvertImage_Callback(
  const AConvertImage_Context: Pointer;
  const AFormatOut: LongWord;
  const AOutputBuffer: Pointer;
  const AOutputSize: LongWord
): Boolean; stdcall;
begin
  Result := FALSE;
  // called from DLLCache_QueryTile_Callback - AConvertImage_Context is ATileInfo: PQueryTileInfo
  if (DLLCACHE_IMG_PRIMARY = AFormatOut) and (AConvertImage_Context <> nil) and (AOutputBuffer <> nil) and (AOutputSize > 0) then begin
    try
      with TMemoryStream(PQueryTileInfo(AConvertImage_Context)^.TileStream) do begin
        WriteBuffer(AOutputBuffer^, AOutputSize);
        Position := 0;
      end;
      Inc(Result);
    except
    end;
  end;
end;

function DLLCache_EnumTileVersions_Callback(
  const AContext: Pointer;
  const AEnumInfo: PEnumTileVersionsInfo;
  const AVersionString: PAnsiChar
): Boolean; stdcall;
var
  VVersionString: AnsiString;
begin
  Result := FALSE;
  // if AVersionString is NULL - it means NO VERSION aka CLEAR - do not enum it
  if (nil <> AEnumInfo) and (nil <> AVersionString) then begin
    try
      // make list
      if (nil = AEnumInfo^.ListOfVersions) then begin
        AEnumInfo^.ListOfVersions := TStringList.Create;
        with TStringList(AEnumInfo^.ListOfVersions) do begin
          Sorted := TRUE;
          Duplicates := dupIgnore;
        end;
      end;
      // make version string
      SetString(VVersionString, AVersionString, StrLen(AVersionString));
      // add if not found
      TStringList(AEnumInfo^.ListOfVersions).Add(VVersionString);
      Inc(Result);
    except
    end;
  end;
end;

function DLLCache_QueryTile_Callback(
  const AContext: Pointer;
  const ATileInfo: PQueryTileInfo;
  const ATileBuffer: Pointer;
  const AVersionString: PAnsiChar
): Boolean; stdcall;
var
  VVersionStoreString: AnsiString;
begin
  Result := FALSE;
  if (nil <> ATileInfo) then begin
    try
      // tile body
      if (nil <> ATileBuffer) and (ATileInfo^.TileSize > 0) and (nil <> ATileInfo^.TileStream) then begin
        if (ATileInfo^.Common.Size >= SizeOf(TQueryTileInfo_V2)) then begin
          // MULTIPLE TYPES! check image type
          case PQueryTileInfo_V2(ATileInfo)^.FormatOut of
            DLLCACHE_IMG_PRIMARY: begin
              // JPEG
              with TMemoryStream(ATileInfo^.TileStream) do begin
                WriteBuffer(ATileBuffer^, ATileInfo^.TileSize);
                Position := 0;
              end;
              Result := TRUE;
            end;
            DLLCACHE_IMG_SEC_DXT1: begin
              // call DLL to CONVERT to JPEG
              Result := TTileStorageDLL(AContext).InternalLib_ConvertImage(ATileInfo, ATileBuffer, ATileInfo^.TileSize);
            end;
          end;
        end else begin
          // ONLY PRIMARY! always convert to primary image format at DLL
          with TMemoryStream(ATileInfo^.TileStream) do begin
            WriteBuffer(ATileBuffer^, ATileInfo^.TileSize);
            Position := 0;
          end;
          // do smth
          Result := TRUE;
        end;
      end;

      // tile version
      if (0 <> (ATileInfo^.Common.FlagsOut and DLLCACHE_QTO_SAME_VERSION)) then begin
        // ok
        Result := TRUE;
      end else if (nil <> AVersionString) and (nil <> AContext) then begin
        // make as string
        SetString(VVersionStoreString, AVersionString, StrLen(AVersionString));
        // make and set version
        IMapVersionInfo(ATileInfo^.VersionOut) := TTileStorageDLL(AContext).MapVersionFactory.CreateByStoreString(VVersionStoreString);
        // do smth
        Result := TRUE;
      end;
    except
    end;
  end;
end;

function HostExifReaderProc(
  const AContext: Pointer;
  const ABuffer: Pointer;
  const ASize: LongWord;
  const AExifBufPtr: PPointer;
  const AExifSizPtr: PLongWord
): Boolean; stdcall;
var
  VExifOffset: PByte;
  VExifSize: Cardinal;
begin
  Result := FALSE;
  try
    if FindExifInJpeg(ABuffer, ASize, TRUE, $0000, VExifOffset, VExifSize) then begin
      AExifBufPtr^ := VExifOffset;
      AExifSizPtr^ := VExifSize;
      Inc(Result);
    end;
  except
  end;
end;

function HostStateChangedProc(
  const AContext: Pointer;
  const AEnabled: Boolean
): Boolean; stdcall;
begin
  Result := FALSE;
  if (nil <> AContext) then begin
    try
      if TTileStorageDLL(AContext).InternalLib_NotifyStateChanged(AEnabled) then begin
        Inc(Result);
      end;
    except
    end;
  end;
end;

{ TTileStorageDLL }

constructor TTileStorageDLL.Create(
  const AConfig: ISimpleTileStorageConfig;
  const AContentTypeManager: IContentTypeManager
);
begin
  inherited Create(TTileStorageTypeAbilitiesGE.Create, TMapVersionFactoryGE.Create, AConfig);
  FDLLSync := MakeSyncRW_Big(Self);
  FTileNotExistsTileInfo := TTileInfoBasicNotExists.Create(0, nil);
  FDLLHandle := 0;
  FDLLCacheHandle := nil;
  InternalLib_CleanupProc;
  FCachedNameInCache := '';
  FMainContentType := AContentTypeManager.GetInfo('image/jpeg'); // ('application/vnd.google-earth.tile-image'); // wtf?
end;

function TTileStorageDLL.DeleteTile(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
): Boolean;
begin
  Result := FALSE;
end;

function TTileStorageDLL.DeleteTNE(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
): Boolean;
begin
  Result := FALSE;
end;

destructor TTileStorageDLL.Destroy;
begin
  StorageStateInternal.ReadAccess := asDisabled;

  FDLLSync.BeginWrite;
  try
    InternalLib_Unload;
  finally
    FDLLSync.EndWrite;
  end;

  FreeAndNil(FCacheConfig);

  FTileNotExistsTileInfo := nil;
  FDLLSync := nil;

  inherited Destroy;
end;

procedure TTileStorageDLL.DoOnMapSettingsEdit(Sender: TObject);
var
  VNameInCache: AnsiString;
  VAccesState: TAccesState;
begin
  if (nil = FCacheConfig) then begin
    Exit;
  end;
  VNameInCache := FCacheConfig.GetNameInCache;
  if not SameText(VNameInCache, FCachedNameInCache) then begin
    // change path
    FDLLSync.BeginWrite;
    try
      VAccesState := StorageStateInternal.ReadAccess;
      StorageStateInternal.ReadAccess := asUnknown;
      FCachedNameInCache := VNameInCache;
      if not InternalLib_SetPath(PAnsiChar(FCachedNameInCache)) then begin
        StorageStateInternal.ReadAccess := VAccesState;
      end;
    finally
      FDLLSync.EndWrite;
    end;
  end;
end;

function TTileStorageDLL.DoOnRangeFillingMap(
  Sender: TObject;
  const ASourceTilesRect: PRect;
  const AVersionInfo: IMapVersionInfo;
  const ARangeFillingMapInfo: PRangeFillingMapInfo
): Boolean;
var
  VVersionInfo: IMapVersionInfo;
  VVersionStoreString: AnsiString;
  VVersionStringPtr: PAnsiChar;
begin
  Result := FALSE;

  if not Assigned(FDLLCache_QueryFillingMap) then begin
    Exit;
  end;

  VVersionInfo := AVersionInfo;
  if Assigned(VVersionInfo) then begin
    VVersionStoreString := VVersionInfo.StoreString;
    VVersionStringPtr := PAnsiChar(VVersionStoreString);
  end else begin
    VVersionStringPtr := nil;
  end;

  try
    Result := TDLLCache_QueryFillingMap(FDLLCache_QueryFillingMap)(@FDLLCacheHandle,
      ASourceTilesRect,
      VVersionStringPtr,
      ARangeFillingMapInfo);
  except
  end;
end;

function TTileStorageDLL.GetAllowDifferentContentTypes: Boolean;
begin
  Result := TRUE;
end;

function TTileStorageDLL.GetCacheConfig: TMapTypeCacheConfigAbstract;
begin
  Result := FCacheConfig;
end;

function TTileStorageDLL.GetListOfTileVersions(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
): IMapVersionListStatic;
var
  VEnumInfo: TEnumTileVersionsInfo;
  VVersionStoreString: AnsiString;
  VList: IInterfaceList;
  VVersion: IMapVersionInfo;
  i: Integer;
begin
  VList := nil;

  FDLLSync.BeginRead;
  try
    if StorageStateStatic.ReadAccess <> asDisabled then begin
      VVersionStoreString := AVersionInfo.StoreString;
      // init
      FillChar(VEnumInfo, sizeof(VEnumInfo), #0);
      VEnumInfo.Common.Size := SizeOf(VEnumInfo);
      VEnumInfo.Common.Zoom := AZoom;
      VEnumInfo.Common.XY := AXY;
      VEnumInfo.Common.VersionInp := PAnsiChar(VVersionStoreString);
      // call
      if InternalLib_GetTileVersions(@VEnumInfo) then begin
        if (nil <> VEnumInfo.ListOfVersions) then begin
          try
            // make version for each item
            if (TStringList(VEnumInfo.ListOfVersions).Count > 0) then begin
              VList := TInterfaceList.Create;
              for i := 0 to TStringList(VEnumInfo.ListOfVersions).Count - 1 do begin
                VVersion := MapVersionFactory.CreateByStoreString(TStringList(VEnumInfo.ListOfVersions).Strings[i]);
                VList.Add(VVersion);
              end;
            end;
          finally
            FreeAndNil(VEnumInfo.ListOfVersions);
          end;
        end;
      end;
    end;
  finally
    FDLLSync.EndRead;
  end;

  Result := TMapVersionListStatic.Create(VList);
end;

function TTileStorageDLL.GetMainContentType: IContentTypeInfoBasic;
begin
  Result := FMainContentType;
end;

function TTileStorageDLL.GetTileFileName(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
): string;
begin
  Abort;
end;

function TTileStorageDLL.GetTileInfo(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
): ITileInfoBasic;
begin
  QueryTileInternal(AXY, AZoom, AVersionInfo, nil, Result);
end;

function TTileStorageDLL.GetTileRectInfo(
  const ARect: TRect;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
): ITileRectInfo;
begin
  Result := nil;
end;

function TTileStorageDLL.InternalLib_CheckInitialized: Boolean;
begin
  Result := (0 <> FDLLHandle) and
    (nil <> FDLLCacheHandle) and
    (nil <> FDLLCache_EnumTileVersions) and
    (nil <> FDLLCache_QueryTile);
  // FDLLCache_ConvertImage and FDLLCache_QueryFillingMap can be NULL
end;

function TTileStorageDLL.InternalLib_CleanupProc: Boolean;
begin
  Result := FALSE;
  OnRangeFillingMap := nil;
  FDLLCache_EnumTileVersions := nil;
  FDLLCache_QueryTile := nil;
  FDLLCache_ConvertImage := nil;
  FDLLCache_QueryFillingMap := nil;
end;

function TTileStorageDLL.InternalLib_ConvertImage(
  const AConvertImage_Context: Pointer;
  const ABuffer: Pointer;
  const ASize: Cardinal
): Boolean;
begin
  Result := FALSE;
  if (nil <> FDLLCache_ConvertImage) then begin
    Result := TDLLCache_ConvertImage(FDLLCache_ConvertImage)(AConvertImage_Context, ABuffer, ASize,
      DLLCACHE_IMG_SEC_DXT1,
      DLLCACHE_IMG_PRIMARY,
      DLLCache_ConvertImage_Callback);
  end;
end;

function TTileStorageDLL.InternalLib_GetTileVersions(const AEnumInfo: PEnumTileVersionsInfo): Boolean;
begin
  Result := FALSE;
  if (nil <> FDLLCache_EnumTileVersions) then begin
    Result := TDLLCache_EnumTileVersions(FDLLCache_EnumTileVersions)(@FDLLCacheHandle, AEnumInfo, DLLCache_EnumTileVersions_Callback);
  end;
end;

function TTileStorageDLL.InternalLib_Initialize: Boolean;
var
  p: Pointer;
begin
  Result := FALSE;
  if (0 <> FDLLHandle) then begin
    // get init proc
    p := GetProcAddress(FDLLHandle, 'DLLCache_Init');
    if (nil <> p) then begin
      Result := TDLLCache_Init(p)(@FDLLCacheHandle, 0, Self);
    end;

    if Result then begin
      // set exif reader
      p := GetProcAddress(FDLLHandle, 'DLLCache_SetInformation');
      if (nil <> p) then begin
        TDLLCache_SetInformation(p)(@FDLLCacheHandle, DLLCACHE_SIC_STATE_CHANGED, 0, @HostStateChangedProc);
        TDLLCache_SetInformation(p)(@FDLLCacheHandle, DLLCACHE_SIC_EXIF_READER, 0, @HostExifReaderProc);
      end;

      // initialized - get other functions
      FDLLCache_EnumTileVersions := GetProcAddress(FDLLHandle, 'DLLCache_EnumTileVersions');
      FDLLCache_QueryTile := GetProcAddress(FDLLHandle, 'DLLCache_QueryTile');
      FDLLCache_ConvertImage := GetProcAddress(FDLLHandle, 'DLLCache_ConvertImage');
      FDLLCache_QueryFillingMap := GetProcAddress(FDLLHandle, 'DLLCache_QueryFillingMap');

      // params
      if Assigned(FDLLCache_QueryFillingMap) then begin
        OnRangeFillingMap := Self.DoOnRangeFillingMap;
      end;
    end;
  end;
end;

function TTileStorageDLL.InternalLib_NotifyStateChanged(const AEnabled: Boolean): Boolean;
var
  VReadAccess: TAccesState;
begin
  Result := FALSE;

  if AEnabled then begin
    VReadAccess := asEnabled;
  end else begin
    VReadAccess := asDisabled;
  end;

  StorageStateInternal.ReadAccess := VReadAccess;
end;

function TTileStorageDLL.InternalLib_QueryTile(const ATileInfo: PQueryTileInfo): Boolean;
begin
  Result := FALSE;
  if (nil <> FDLLCache_QueryTile) then begin
    try
      Result := TDLLCache_QueryTile(FDLLCache_QueryTile)(@FDLLCacheHandle, ATileInfo, DLLCache_QueryTile_Callback);
    except
    end;
  end;
end;

function TTileStorageDLL.InternalLib_SetPath(const APath: PAnsiChar): Boolean;
var
  p: Pointer;
begin
  Result := FALSE;
  try
    if (0 = FDLLHandle) then begin
      InternalLib_Initialize;
    end;
    if InternalLib_CheckInitialized then begin
      p := GetProcAddress(FDLLHandle, 'DLLCache_SetPath');
      if (nil <> p) then begin
        Result := TDLLCache_SetPath(p)(@FDLLCacheHandle, APath);
      end;
    end;
  finally
    InternalLib_NotifyStateChanged(Result);
  end;
end;

function TTileStorageDLL.InternalLib_Unload: Boolean;
var
  p: Pointer;
begin
  Result := FALSE;
  if (0 <> FDLLHandle) then begin
    // uninit
    p := GetProcAddress(FDLLHandle, 'DLLCache_Uninit');
    if (nil <> p) then begin
      TDLLCache_Uninit(p)(@FDLLCacheHandle);
    end;

    // finishing
    Inc(Result);
    FreeLibrary(FDLLHandle);
    FDLLHandle := 0;
    InternalLib_CleanupProc;
    InternalLib_NotifyStateChanged(FALSE);
  end;
end;

function TTileStorageDLL.LoadTile(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo;
  out ATileInfo: ITileInfoBasic
): IBinaryData;
var
  VMemStream: TMemoryStream;
begin
  Result := nil;
  VMemStream := TMemoryStream.Create;
  try
    if QueryTileInternal(AXY, AZoom, AVersionInfo, VMemStream, ATileInfo) then begin
      Result := TBinaryDataByMemStream.CreateWithOwn(VMemStream);
      VMemStream := nil;
    end;
  finally
    VMemStream.Free;
  end;
end;

function TTileStorageDLL.QueryTileInternal(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo;
  AStream: TMemoryStream;
  out ATileInfo: ITileInfoBasic
): Boolean;
var
  VVersionInfo: IMapVersionInfo;
  VVersionStoreString: AnsiString;
  VQTInfo: TQueryTileInfo;
begin
  Result := FALSE;
  ATileInfo := nil;

  FDLLSync.BeginRead;
  try
    if StorageStateStatic.ReadAccess <> asDisabled then begin
      VVersionInfo := AVersionInfo;
      VVersionStoreString := VVersionInfo.StoreString;
      // init
      FillChar(VQTInfo, SizeOf(VQTInfo), #0);
      VQTInfo.Common.Size := SizeOf(VQTInfo);
      VQTInfo.Common.Zoom := AZoom;
      VQTInfo.Common.XY := AXY;
      VQTInfo.Common.VersionInp := PAnsiChar(VVersionStoreString);

      // load tile body or not
      if (nil <> AStream) then begin
        VQTInfo.Common.FlagsInp := DLLCACHE_QTI_LOAD_TILE;
        VQTInfo.TileStream := AStream;
      end;

      try
        // call
        if InternalLib_QueryTile(@VQTInfo) then begin
          // check version
          if (nil = VQTInfo.VersionOut) then begin
            // no output version - may be _the_same_ version
            if (0 <> (VQTInfo.Common.FlagsOut and DLLCACHE_QTO_SAME_VERSION)) then begin
              IMapVersionInfo(VQTInfo.VersionOut) := AVersionInfo;
            end;
          end;

          // check size
          if (VQTInfo.TileSize > 0) then begin
            // tile exists
            ATileInfo := TTileInfoBasicExists.Create(
              VQTInfo.DateOut,
              VQTInfo.TileSize,
              IMapVersionInfo(VQTInfo.VersionOut),
              FMainContentType
            );
            Inc(Result);
          end else if (0 <> (VQTInfo.Common.FlagsOut and DLLCACHE_QTO_TNE_EXISTS)) then begin
            // tne found
            ATileInfo := TTileInfoBasicTNE.Create(VQTInfo.DateOut, IMapVersionInfo(VQTInfo.VersionOut));
          end else begin
            // nothing
            ATileInfo := FTileNotExistsTileInfo;
          end;
        end else begin
          // nothing
          ATileInfo := FTileNotExistsTileInfo;
        end;
      finally
        IMapVersionInfo(VQTInfo.VersionOut) := nil;
      end;
    end;
  finally
    FDLLSync.EndRead;
  end;
end;

procedure TTileStorageDLL.SaveTile(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo;
  const AData: IBinaryData
);
begin
  Abort;
end;

procedure TTileStorageDLL.SaveTNE(
  const AXY: TPoint;
  const AZoom: byte;
  const AVersionInfo: IMapVersionInfo
);
begin
  Abort;
end;

{ TTileStorageGE }

constructor TTileStorageGE.Create(
  const AConfig: ISimpleTileStorageConfig;
  AGlobalCacheConfig: TGlobalCahceConfig;
  const AContentTypeManager: IContentTypeManager
);
begin
  inherited Create(AConfig, AContentTypeManager);
  FCacheConfig := TMapTypeCacheConfigGE.Create(AConfig, AGlobalCacheConfig, Self.DoOnMapSettingsEdit);
  InternalLib_Initialize;
  DoOnMapSettingsEdit(nil);
end;

function TTileStorageGE.GetRangeFillingMapItemSize: SmallInt;
begin
  // there are no loading tile dates in GE cache - just flags
  Result := SizeOf(TRangeFillingItem1);
end;

function TTileStorageGE.InternalLib_CheckInitialized: Boolean;
begin
  // common checks
  Result := inherited InternalLib_CheckInitialized;
  (*
  if Result then begin
    // special checks
  end;
  *)
end;

function TTileStorageGE.InternalLib_Initialize: Boolean;
begin
  if (0 = FDLLHandle) then begin
    FDLLHandle := LoadLibrary('TileStorage_GE.dll');
  end;

  // common routines
  Result := inherited InternalLib_Initialize;
  (*
  if Result then begin
    // special routines
  end;
  *)
end;

{ TTileStorageGC }

constructor TTileStorageGC.Create(
  const AConfig: ISimpleTileStorageConfig;
  AGlobalCacheConfig: TGlobalCahceConfig;
  const AContentTypeManager: IContentTypeManager
);
begin
  inherited Create(AConfig, AContentTypeManager);
  FCacheConfig := TMapTypeCacheConfigGC.Create(AConfig, AGlobalCacheConfig, Self.DoOnMapSettingsEdit);
  InternalLib_Initialize;
  DoOnMapSettingsEdit(nil);
end;

function TTileStorageGC.GetRangeFillingMapItemSize: SmallInt;
begin
  // there are loading tile dates in GC cache - datetime up to minute and flags
  Result := SizeOf(TRangeFillingItem4);
end;

function TTileStorageGC.InternalLib_CheckInitialized: Boolean;
begin
  // common checks
  Result := inherited InternalLib_CheckInitialized;
  (*
  if Result then begin
    // special checks
  end;
  *)
end;

function TTileStorageGC.InternalLib_Initialize: Boolean;
begin
  if (0 = FDLLHandle) then begin
    FDLLHandle := LoadLibrary('TileStorage_GC.dll');
  end;

  // common routines
  Result := inherited InternalLib_Initialize;
  (*
  if Result then begin
    // special routines
  end;
  *)
end;

end.
