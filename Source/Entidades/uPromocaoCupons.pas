unit uPromocaoCupons;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPromocaoCupons = class(TInterfacedObject, iEntidade)
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

{ TPromocaoCupons }

constructor TPromocaoCupons.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select pc.*, co.nome, co.fone, co.celular ' +
    'from promocao_cupons pc ' +
    'join consumidor co on (co.cpfcnpj = pc.cpfcnpj) ' +
    'where pc.id_promocao = :pId_promocao');
  InicializaDataSource;
end;

destructor TPromocaoCupons.Destroy;
begin
  inherited;
end;

class function TPromocaoCupons.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPromocaoCupons.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPromocaoCupons.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    //busca por Cupom
    0: vTextoSQL:= vTextoSQL + ' and pc.numero_cupom = :pParametro';
    //busca por Cpf/cnpj
    1: vTextoSQL:= vTextoSQL + ' and pc.cpfcnpj = :pParametro';
    //busca por Nome
    2: vTextoSQL:= vTextoSql + ' and co.nome containing :pParametro';
    //Busca por sorteado
    3: vTextoSQL:= vTextoSQL + ' and pc.sorteado = ''S'' ';
  end;
  FEntidadeBase.Iquery.IndexFieldNames('NUMERO_CUPOM');
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPromocaoCupons.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select pc.*, co.nome, co.fone, co.celular from promocao_cupons pc join consumidor co on (co.cpfcnpj = pc.cpfcnpj) Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPromocaoCupons.ModificaDisplayCampos;
begin

end;

function TPromocaoCupons.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
