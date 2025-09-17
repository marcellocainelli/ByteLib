unit Model.Query.Firedac;
interface
uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Variants,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Script,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  Model.Conexao.Firedac,
  Model.Conexao.Interfaces;
Type
  TModelQueryFiredac = class(TInterfacedObject, iQuery)
    private
      FParent: iConexao;
      FDQuery: TFDQuery;
      FUpdateTransaction: TFDTransaction;
      FScript: TFDScript;
    public
      constructor Create(Parent: iConexao);
      destructor Destroy; override;
      class function New(Parent: iConexao): iQuery;
      function SQL(Value: String = ''): iQuery;
      function Dataset: TDataSet;
      function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iQuery; overload;
      function AddParametro(NomeParametro: String; ValorParametro: integer): iQuery; overload;
      function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType; FilePath: String): iQuery; overload;
      function AddParametro(NomeParametro: String; DataType: TFieldType; Stream: TStream): iQuery; overload;
      function Close: iQuery;
      function ExecQuery(Value: String): iQuery;
      function Salva(Commit: Boolean = True): iQuery;
      function ApplyUpdates: iQuery;
      function IndexFieldNames(FieldName: String): iQuery;
      function StartTransaction: iQuery;
      function InTransaction: Boolean;
      function Commit: iQuery;
      function Rollback: iQuery;
      function ChangeCount(DataSet: TDataSet): integer;
      function GetFieldNames(Table: string; List: TStrings): iQuery;
      function SetMode(pModo: string): iQuery;
      function CalcFields(AEvent: TDataSetNotifyEvent): iQuery;
      function ClearDataset(Value: TDataSet): iQuery;
      function FetchOptions(AMode: String = ''; ARowSetSize: integer = 0): iQuery;
      procedure CatchApplyUpdatesErrors;
      function TrataErrosApplyUpdates(AMsgErro: string): string;
      function InsertNewRecordEvent(AEvent: TDataSetNotifyEvent = nil): iQuery;
      function SQL_Add(ASQL: string; AClearBeforeAdd: Boolean = false): iQuery;
      function SaveFileFromField(AFieldName, AFilePath: String): Boolean;
      function CaminhoBD: String;
      function Password: String;
  end;
implementation
{ TModelQueryFiredac }
constructor TModelQueryFiredac.Create(Parent: iConexao);
begin
  FParent:= Parent;
  FDQuery:= TFDQuery.Create(nil);
  FUpdateTransaction:= TFDTransaction.Create(nil);
  if not Assigned(FParent) then
    FParent:= TModelConexaoFiredac.New;
  FDQuery.Connection:= TFDConnection(FParent.Connection);
  FDQuery.ResourceOptions.ParamCreate := False;
  FDQuery.CachedUpdates:= True;
  FUpdateTransaction.Connection:= TFDConnection(FParent.Connection);
end;

function TModelQueryFiredac.Dataset: TDataSet;
begin
  Result:= FDQuery;
end;

destructor TModelQueryFiredac.Destroy;
begin
  FreeAndNil(FDQuery);
  FreeAndNil(FUpdateTransaction);
  FreeAndNil(FScript);
  inherited;
end;

class function TModelQueryFiredac.New(Parent: iConexao): iQuery;
begin
  Result:= Self.Create(Parent);
end;

function TModelQueryFiredac.SQL(Value: String): iQuery;
begin
  Result:= Self;
  FDQuery.Close;
  if not Value.IsEmpty then begin
    FDQuery.SQL.Clear;
    FDQuery.SQL.Add(Value);
  end;
  FDQuery.Active:= true;
end;

function TModelQueryFiredac.SQL_Add(ASQL: string; AClearBeforeAdd: Boolean): iQuery;
begin
  Result:= Self;
  if AClearBeforeAdd then
    FDQuery.SQL.Clear;
  FDQuery.SQL.Add(ASQL);
end;

function TModelQueryFiredac.ExecQuery(Value: String): iQuery;
begin
  Result:= Self;
  FDQuery.Close;
  FDQuery.SQL.Clear;
  FDQuery.SQL.Add(Value);
  FDQuery.ExecSQL;
 end;

function TModelQueryFiredac.FetchOptions(AMode: String; ARowSetSize: integer): iQuery;
begin
  if AMode = 'Demand' then
    FDQuery.FetchOptions.Mode:= fmOnDemand
  else if AMode = 'All' then
    FDQuery.FetchOptions.Mode:= fmAll;

  if ARowSetSize <> 0 then
    FDQuery.FetchOptions.RowsetSize:= ARowSetSize;
end;

function TModelQueryFiredac.GetFieldNames(Table: string; List: TStrings): iQuery;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).GetFieldNames('', '', Table, '', List);
end;
function TModelQueryFiredac.AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iQuery;
begin
  Result:= Self;
  FDQuery.Params.Add.Name:= NomeParametro;
  FDQuery.Params.ParamValues[NomeParametro]:= ValorParametro;
  FDQuery.Params.Add.DataType:= DataType;
  if DataType = ftString then
    FDQuery.Params.Add.Size:= Length(NomeParametro);
  FDQuery.Params.Add.ParamType:= ptInput;
end;

function TModelQueryFiredac.AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType; FilePath: String): iQuery;
var
  BlobField: TFDParam;
begin
  Result := Self;

  if (FilePath <> '') and (DataType = ftBlob) then begin
    BlobField := FDQuery.Params.Add;
    BlobField.Name := NomeParametro;
    BlobField.DataType := DataType;
    BlobField.ParamType := ptInput;
    BlobField.LoadFromFile(FilePath, ftBlob);
  end;
end;

function TModelQueryFiredac.AddParametro(NomeParametro: String; ValorParametro: integer): iQuery;
begin
  Result:= Self;
  FDQuery.Params.Add.Name:= NomeParametro;
  FDQuery.Params.ParamValues[NomeParametro]:= ValorParametro;
  FDQuery.Params.Add.DataType:= ftInteger;
  FDQuery.Params.Add.ParamType:= ptInput;
end;

function TModelQueryFiredac.AddParametro(NomeParametro: String; DataType: TFieldType; Stream: TStream): iQuery;
var
  BlobField: TFDParam;
begin
  Result:= Self;
  if (DataType = ftBlob) then begin
    BlobField := FDQuery.Params.Add;
    BlobField.Name := NomeParametro;
    BlobField.DataType := DataType;
    BlobField.ParamType := ptInput;
    BlobField.LoadFromStream(Stream, ftBlob);
  end;
end;

function TModelQueryFiredac.Close: iQuery;
begin
  Result:= Self;
  FDQuery.Close;
end;
//http://docwiki.embarcadero.com/RADStudio/Sydney/en/Caching_Updates_(FireDAC)
//function TModelQueryFiredac.Salva(Commit: Boolean = True): iQuery;
//begin
//  Result:= Self;
//  if not InTransaction then
//    TFDConnection(FParent.Connection).StartTransaction;
//  Try
//    If FDQuery.ApplyUpdates(0) > 0 then
//      CatchApplyUpdatesErrors;
//    FDQuery.CommitUpdates;
//    if Commit then
//      TFDConnection(FParent.Connection).Commit;
//  except
//    on E:Exception do begin
//      TFDConnection(FParent.Connection).Rollback;
//      raise Exception.Create(E.Message);
//    end;
//  end;
//end;
function TModelQueryFiredac.Salva(Commit: Boolean = True): iQuery; //alterada em 31/10/2024
var
  CrieiTransaction: Boolean;
begin
  Result:= Self;

  CrieiTransaction:= False;
  if not InTransaction then begin
    CrieiTransaction:= True;
    TFDConnection(FParent.Connection).StartTransaction;
  end;

  Try
    if FDQuery.ApplyUpdates(0) > 0 then
      CatchApplyUpdatesErrors;
    FDQuery.CommitUpdates;
    if Commit then
      TFDConnection(FParent.Connection).Commit;
  except
    on E:Exception do begin
      if CrieiTransaction then
        TFDConnection(FParent.Connection).Rollback;
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TModelQueryFiredac.SaveFileFromField(AFieldName, AFilePath: String): Boolean;
var
  BlobStream: TStringStream;
begin
  Result:= False;
  try
    if (FDQuery = nil) or (FDQuery.FieldByName(AFieldName) = nil) then
      raise Exception.Create('Dataset ou campo inválido.');

    BlobStream:= TStringStream.Create;
    try
      TBlobField(FDQuery.FieldByName(AFieldName)).SaveToStream(BlobStream);
      // Posiciona o stream no início
      BlobStream.Position := 0;
      // Salva o conteúdo do stream para um arquivo
      BlobStream.SaveToFile(AFilePath);
      Result:= True;
    finally
      BlobStream.Free;
    end;
  except
    on E:Exception do begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TModelQueryFiredac.SetMode(pModo: string): iQuery;
begin
  Result:= Self;
  FDQuery.FetchOptions.Mode:= fmAll;
end;
function TModelQueryFiredac.IndexFieldNames(FieldName: String): iQuery;
begin
  Result:= Self;
  FDQuery.IndexFieldNames:= FieldName;
end;
function TModelQueryFiredac.InsertNewRecordEvent(AEvent: TDataSetNotifyEvent): iQuery;
begin
  Result:= Self;
  FDQuery.OnNewRecord:= AEvent;
end;

function TModelQueryFiredac.InTransaction: Boolean;
begin
  Result:= TFDConnection(FParent.Connection).InTransaction;
end;
function TModelQueryFiredac.StartTransaction: iQuery;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).StartTransaction;
end;
function TModelQueryFiredac.Commit: iQuery;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).Commit;
end;
function TModelQueryFiredac.Rollback: iQuery;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).Rollback;
end;
function TModelQueryFiredac.ApplyUpdates: iQuery;
begin
  Result:= Self;
  try
    FDQuery.ApplyUpdates(0);
    FDQuery.CommitUpdates;
  except
    on E:Exception do
      raise Exception.Create('Ocorreu um erro ao tentar gravar o registro: ' + E.Message);
  end;
end;
function TModelQueryFiredac.ChangeCount(DataSet: TDataSet): integer;
begin
  Result:= TFDQuery(DataSet).ChangeCount;
end;
function TModelQueryFiredac.CalcFields(AEvent: TDataSetNotifyEvent): iQuery;
begin
  Result:= Self;
  FDQuery.OnCalcFields:= AEvent;
end;

function TModelQueryFiredac.ClearDataset(Value: TDataSet): iQuery;
begin
  Result:= Self;
  TFDQuery(Value).EmptyDataSet;
end;
procedure TModelQueryFiredac.CatchApplyUpdatesErrors;
var
  oErr: EFDException;
begin
  FDQuery.FilterChanges:= [rtModified, rtInserted, rtDeleted, rtHasErrors];
  try
    FDQuery.First;
    while not FDQuery.Eof do begin
      oErr:= FDQuery.RowError;
      if oErr <> nil then begin
        raise Exception.Create(TrataErrosApplyUpdates(oErr.Message));
      end;
      FDQuery.Next;
    end;
  finally
    FDQuery.FilterChanges:= [rtUnModified, rtModified, rtInserted];
  end;
end;
function TModelQueryFiredac.TrataErrosApplyUpdates(AMsgErro: string): string;
begin
  Result:= AMsgErro;
  if AMsgErro.Contains('violation of PRIMARY or UNIQUE KEY') then
    Result:= 'Código já cadastrado!';
end;

function TModelQueryFiredac.CaminhoBD: String;
begin
  Result:= FDQuery.Connection.Params.Database;
end;

function TModelQueryFiredac.Password: String;
begin
  Result:= FDQuery.Connection.Params.Password;
end;

end.
