unit uOrdemEquipamento;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TOrdemEquipamento = class(TInterfacedObject, iEntidade)
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

{ TOrdemEquipamento }

constructor TOrdemEquipamento.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_EQUIPAMENTOS ');
end;

destructor TOrdemEquipamento.Destroy;
begin
  inherited;
end;

class function TOrdemEquipamento.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdemEquipamento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdemEquipamento.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdemEquipamento.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TOrdemEquipamento.ModificaDisplayCampos;
begin

end;

end.
