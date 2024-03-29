unit uNatureza;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TNatureza = class(TInterfacedObject, iEntidade)
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

{ TNatureza }

constructor TNatureza.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select N.*, 0 as INDICE from NATUREZA N  Where (1 = 1) ');

  InicializaDataSource;
end;

destructor TNatureza.Destroy;
begin
  inherited;
end;

class function TNatureza.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNatureza.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNatureza.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('HISTORICO');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNatureza.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('HISTORICO');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNatureza.ModificaDisplayCampos;
begin

end;

function TNatureza.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
