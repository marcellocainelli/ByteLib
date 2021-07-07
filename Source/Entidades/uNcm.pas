unit uNcm;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TCst = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TCst }

constructor TCst.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select N.*, I.DESCRICAO as DESCR_IPIPISCOFINS ' +
    'from NCM N ' +
    'Left Join PRODUTOS_IMPOSTOS I on (I.CODIGO = N.COD_IPIPISCOFINS) ');
end;

destructor TCst.Destroy;
begin
  inherited;
end;

class function TCst.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCst.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCst.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where N.CLASFISCAL = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' Where N.DESCRICAO CONTAINING :Parametro';
  end;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  FEntidadeBase.Iquery.IndexFieldNames('NCM');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCst.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TCst.ModificaDisplayCampos;
begin

end;

end.
