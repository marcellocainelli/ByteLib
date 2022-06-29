unit uEtiquetasFast;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TEtiquetasFast = class(TInterfacedObject, iEntidade)
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

{ TEtiquetasFast }

constructor TEtiquetasFast.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ETIQUETAS_FAST');

  InicializaDataSource;
end;

destructor TEtiquetasFast.Destroy;
begin
  inherited;
end;

class function TEtiquetasFast.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEtiquetasFast.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEtiquetasFast.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEtiquetasFast.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From ETIQUETAS_FAST Where 1 <> 1';
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEtiquetasFast.ModificaDisplayCampos;
begin

end;

function TEtiquetasFast.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
