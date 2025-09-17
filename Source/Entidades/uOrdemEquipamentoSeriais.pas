unit uOrdemEquipamentoSeriais;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TOrdemEquipamentoSeriais = class(TInterfacedObject, iEntidade)
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

{ TOrdemEquipamentoSeriais }

constructor TOrdemEquipamentoSeriais.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_EQUIPAMENTOS_SERIAIS ');
  InicializaDataSource;
end;

destructor TOrdemEquipamentoSeriais.Destroy;
begin
  inherited;
end;

class function TOrdemEquipamentoSeriais.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdemEquipamentoSeriais.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdemEquipamentoSeriais.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' where COD_EQUIPAMENTO = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' where SERIAL = :Parametro';
  end;
  vTextoSQL:= vTextoSQL + ' and ((:pStatus = ''-1'') or (STATUS = :pStatus))';
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('SERIAL');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdemEquipamentoSeriais.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrdemEquipamentoSeriais.ModificaDisplayCampos;
begin

end;

function TOrdemEquipamentoSeriais.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
