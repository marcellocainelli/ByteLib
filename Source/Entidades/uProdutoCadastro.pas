unit uProdutoCadastro;

interface

uses
  Data.DB, System.SysUtils, Model.Entidade.Interfaces;

Type
  TProdutoCadastro = class(TInterfacedObject, iEntidadeProduto)
    private
      FEntidadeBase: iEntidadeBase<iEntidadeProduto>;
      FValidaDepto: Boolean;
      FCodDeptoUsuario: integer;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidadeProduto;
      function EntidadeBase: iEntidadeBase<iEntidadeProduto>;
      function Consulta(Value: TDataSource): iEntidadeProduto;
      function InicializaDataSource(Value: TDataSource): iEntidadeProduto;

      function ValidaDepto(pValue: boolean): iEntidadeProduto; overload;
      function ValidaDepto: boolean; overload;
      function CodDeptoUsuario(pValue: Integer ): iEntidadeProduto; overload;
      function CodDeptoUsuario: Integer ; overload;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uDmFuncoes, uEntidadeBase;

{ TProduto }

constructor TProdutoCadastro.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidadeProduto>.New(Self);
  FEntidadeBase.TextoSQL(
              'Select A.*, B.QUANTIDADE ' +
              'From PRODUTOS A ' +
              'Left Join ESTOQUEFILIAL B on (A.COD_PROD = B.COD_PROD and B.COD_FILIAL = :mCodFilial)' +
              'Where STATUS = ''A'' ' +
              'and ((A.COD_MARCA = :mCOD_MARCA) or (:mCOD_MARCA = -1)) ' +
              'and ((A.COD_MARCA1 = :mCOD_MARCA1) or (:mCOD_MARCA1 = -1)) ' +
              'and ((A.COD_SUBGRUPO = :mCOD_SUBGRUPO) or (:mCOD_SUBGRUPO = -1)) ' +
              'and ((A.COD_FORNEC = :mCOD_FORNEC) or (:mCOD_FORNEC = -1))');
end;

destructor TProdutoCadastro.Destroy;
begin
  inherited;
end;

class function TProdutoCadastro.New: iEntidadeProduto;
begin
  Result:= Self.Create;
end;

function TProdutoCadastro.EntidadeBase: iEntidadeBase<iEntidadeProduto>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoCadastro.Consulta(Value: TDataSource): iEntidadeProduto;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSql;

  If FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');

  //busca por descrição
  vTextoSQL:= vTextoSQL + ' and upper(A.NOME_PROD) ' + FEntidadeBase.RegraPesquisa + ' upper(:mParametro)';

  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSQL);

  ModificaDisplayCampos;

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoCadastro.InicializaDataSource(Value: TDataSource): iEntidadeProduto;
var
  vTextoSQL: String;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSQL + ' and P.COD_PROD = :mParametro and P.STATUS = ''A'' Order By 2';
  FEntidadeBase.AddParametro('mCodFilial', 1, ftInteger);
  FEntidadeBase.AddParametro('mParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(vTextoSql);

  ModificaDisplayCampos;

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoCadastro.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRAZO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ESTOQUE')).DisplayFormat:= '#,0.00';
end;

function TProdutoCadastro.ValidaDepto: boolean;
begin
  Result:= FValidaDepto;
end;

function TProdutoCadastro.ValidaDepto(pValue: boolean): iEntidadeProduto;
begin
  Result:= Self;
  FValidaDepto:= pValue;
end;

function TProdutoCadastro.CodDeptoUsuario: Integer;
begin
  Result:= FCodDeptoUsuario;
end;

function TProdutoCadastro.CodDeptoUsuario(pValue: Integer): iEntidadeProduto;
begin
  Result:= Self;
  FCodDeptoUsuario:= pValue;
end;

end.
