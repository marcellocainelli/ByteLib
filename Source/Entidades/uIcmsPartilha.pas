unit uIcmsPartilha;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TIcmsPartilha = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TIcmsPartilha }

constructor TIcmsPartilha.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ICMS_PARTILHA');
  InicializaDataSource;
end;

destructor TIcmsPartilha.Destroy;
begin
  inherited;
end;

class function TIcmsPartilha.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TIcmsPartilha.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TIcmsPartilha.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ESTADO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TIcmsPartilha.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From ICMS_PARTILHA Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TIcmsPartilha.ModificaDisplayCampos;
begin

end;

function TIcmsPartilha.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
