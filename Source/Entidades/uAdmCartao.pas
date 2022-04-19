unit uAdmCartao;
interface
uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TAdmCartao = class(TInterfacedObject, iEntidade)
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
{ TAdmCartao }
constructor TAdmCartao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select C.*, null as INDICE from CARTAO_ADMINISTRADORA C where (1 = 1) ');
end;
destructor TAdmCartao.Destroy;
begin
  inherited;
end;
class function TAdmCartao.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TAdmCartao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TAdmCartao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and C.STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TAdmCartao.InicializaDataSource(Value: TDataSource): iEntidade;
begin
end;
procedure TAdmCartao.ModificaDisplayCampos;
begin
end;
end.
