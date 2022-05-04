unit uNcm;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TNcm = class(TInterfacedObject, iEntidade)
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

{ TNcm }

constructor TNcm.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select N.*, I.DESCRICAO as DESCR_IPIPISCOFINS ' +
    'from NCM N ' +
    'Left Join PRODUTOS_IMPOSTOS I on (I.CODIGO = N.COD_IPIPISCOFINS) ');

  InicializaDataSource;
end;

destructor TNcm.Destroy;
begin
  inherited;
end;

class function TNcm.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNcm.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNcm.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where N.CLASFISCAL = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' Where N.DESCRICAO CONTAINING :Parametro';
  end;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  FEntidadeBase.Iquery.IndexFieldNames('NCM');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNcm.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From NCM Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNcm.ModificaDisplayCampos;
begin

end;

function TNcm.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
