unit uPrecosItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils, StrUtils;

Type
  TPrecosItens = class(TInterfacedObject, iEntidadeProduto)
    private
      FEntidadeBase: iEntidadeBase<iEntidadeProduto>;
      FValidaDepto: Boolean;
      FCodDeptoUsuario: integer;
      FTipoConsulta: string;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidadeProduto;
      function EntidadeBase: iEntidadeBase<iEntidadeProduto>;
      function Consulta(Value: TDataSource = nil): iEntidadeProduto;
      function InicializaDataSource(Value: TDataSource = nil): iEntidadeProduto;
      function DtSrc: TDataSource;
      function ValidaDepto(pValue: boolean): iEntidadeProduto; overload;
      function ValidaDepto: boolean; overload;
      function CodDeptoUsuario(pValue: Integer): iEntidadeProduto; overload;
      function CodDeptoUsuario: Integer; overload;
      function TipoConsulta(pValue: String): iEntidadeProduto; overload;
      function TipoConsulta: String; overload;
      procedure ModificaDisplayCampos;
      procedure SelecionaSQLConsulta;
  end;

implementation

uses
  uEntidadeBase;

{ TPrecosItens }

constructor TPrecosItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidadeProduto>.New(Self);
  FTipoConsulta:= 'Filtra';

  InicializaDataSource;
end;

procedure TPrecosItens.SelecionaSQLConsulta;
begin
  case AnsiIndexStr(TipoConsulta, ['Consulta', 'Filtra','Produto']) of
  0: FEntidadeBase.TextoSQL(
      'select pi.*, p.nome_prod, p.preco_cust, p.preco_vend ' +
      'from preco_itens pi ' +
      'join produtos p on (p.cod_prod = pi.cod_prod) ' +
      'where p.status = ''A'' and pi.cod_precos = :pCod_Precos ');
  1: FEntidadeBase.TextoSQL(
      'select pi.*, p.nome_prod, p.preco_cust, p.preco_vend ' +
      'from preco_itens pi ' +
      'join produtos p on (p.cod_prod = pi.cod_prod) ' +
      'where p.status = ''A'' and pi.cod_precos = :pCod_Precos ' +
      'and ((P.COD_MARCA = :mCOD_MARCA) or (:mCOD_MARCA = -1)) ' +
      'and ((P.COD_MARCA1 = :mCOD_MARCA1) or (:mCOD_MARCA1 = -1)) ' +
      'and ((P.COD_SUBGRUPO = :mCOD_SUBGRUPO) or (:mCOD_SUBGRUPO = -1)) ' +
      'and ((P.COD_FORNEC = :mCOD_FORNEC) or (:mCOD_FORNEC = -1)) ' +
      'and p.nome_prod Containing :pNome_prod');
  2: FEntidadeBase.TextoSQL(
      'Select p.descricao as nome_prod, p.preco_cust, pi.preco, pi.preco as preco_vend, (((pi.preco / pd.preco_cust) - 1) *100) as multiplicador ' +
      'from preco_itens pi ' +
      'join precos p on (p.codigo = pi.cod_precos) ' +
      'join produtos pd on (pd.cod_prod = pi.cod_prod) ' +
      'where pi.cod_prod = :pCod_prod');
  end;
end;

destructor TPrecosItens.Destroy;
begin
  inherited;
end;

class function TPrecosItens.New: iEntidadeProduto;
begin
  Result:= Self.Create;
end;

function TPrecosItens.EntidadeBase: iEntidadeBase<iEntidadeProduto>;
begin
  Result:= FEntidadeBase;
end;

function TPrecosItens.Consulta(Value: TDataSource): iEntidadeProduto;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPrecosItens.InicializaDataSource(Value: TDataSource): iEntidadeProduto;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPrecosItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('preco_cust')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('preco_vend')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('preco')).currency:= True;
  If FTipoConsulta = 'Produto' then
    TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('multiplicador')).DisplayFormat:= '#,0.00';
end;

function TPrecosItens.ValidaDepto: boolean;
begin
  Result:= FValidaDepto;
end;

function TPrecosItens.ValidaDepto(pValue: boolean): iEntidadeProduto;
begin
  Result:= Self;
  FValidaDepto:= pValue;
end;

function TPrecosItens.CodDeptoUsuario: Integer;
begin
  Result:= FCodDeptoUsuario;
end;

function TPrecosItens.CodDeptoUsuario(pValue: Integer): iEntidadeProduto;
begin
  Result:= Self;
  FCodDeptoUsuario:= pValue;
end;

function TPrecosItens.TipoConsulta: String;
begin
  Result:= FTipoConsulta;
end;

function TPrecosItens.TipoConsulta(pValue: String): iEntidadeProduto;
begin
  Result:= Self;
  FTipoConsulta:= pValue;
end;

function TPrecosItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
