unit uNfeItens;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils, Byte.Lib;
Type
  TNfeItens = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create(AConn: iConexao = nil);
      destructor Destroy; override;
      class function New(AConn: iConexao = nil): iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TNfeItens }

constructor TNfeItens.Create(AConn: iConexao);
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  FEntidadeBase.TipoPesquisa(0);
  FEntidadeBase.TextoSQL(
    'select nfi.*, p.clasfiscal, p.ipi_saida, p.icms as codicms, p.listserv, p.preco_vend as preco_tabela, ' +
    'p.ppb, p.cod_barra, p.cod_anp, p.complemento, p.cest, p.volume, p.peso, p.unidade_comercial ' +
    'from nfiscal_itens nfi ' +
    'join produtos p on (p.cod_prod = nfi.cod_prod) ' +
    'where (1 = 1) and ');
  InicializaDataSource;
end;

destructor TNfeItens.Destroy;
begin
  inherited;
end;

class function TNfeItens.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TNfeItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfeItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + 'NFI.NFNUMERO = :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NFNUMERO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['VrCalculado', 'preco_liquido'],[ftCurrency, ftCurrency]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function TNfeItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NFNUMERO');
  FEntidadeBase.AddParametro('mcodfilial', 1);
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + 'NFI.NFNUMERO = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfeItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('quantidade')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('preco_vend')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vrcalculado')).currency:= True;
end;

function TNfeItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
