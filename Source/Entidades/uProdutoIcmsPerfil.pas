unit uProdutoIcmsPerfil;

{ Entidade da tabela PRODUTO_ICMS_PERFIL (COD_PRODUTO, PERFIL, COD_ICMS).
  ICMS diferenciado por produto conforme o perfil do cliente (ex.: 'P' = Produtor Rural). }

interface

uses
  Model.Entidade.Interfaces, Data.DB,  SysUtils, Dialogs;
Type
  TProdutoIcmsPerfil = class(TInterfacedObject, iEntidade)
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

{ TProdutoIcmsPerfil }

constructor TProdutoIcmsPerfil.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select pip.*, ' +
    '       case pip.perfil when ''P'' then ''Produtor Rural'' else pip.perfil end as desc_perfil, ' +
    '       i.cfop, i.sittributaria as cst ' +
    'from PRODUTOS_ICMS_PERFIL pip ' +
    'left join ICMS i On (i.COD_ICMS = pip.COD_ICMS) and (i.cod_filial = :pCod_Filial) ' +
    'where pip.COD_PRODUTO = :pCod_Prod');
  InicializaDataSource;
end;

destructor TProdutoIcmsPerfil.Destroy;
begin
  inherited;
end;

class function TProdutoIcmsPerfil.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoIcmsPerfil.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoIcmsPerfil.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('PERFIL');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoIcmsPerfil.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.AddParametro('pCod_Prod', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoIcmsPerfil.ModificaDisplayCampos;
begin

end;

function TProdutoIcmsPerfil.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
