/*De um modo geral, ao invés de um REBUILD, prefira executar o comando ALTER INDEX ... COALESCE.
pois ele não tem a mesma sobrecarga do REBUILD, podendo deste modo, ser executado em modo online (com os sistemas em execução).
Apesar do COALESCE não fazer uma reestruturação completa dos índices (como o REBUILD faz), ele faz uma desfragmentação combinando os dados dos blocos das folhas,
liberando desse modo, blocos que poderão ser usados para novas entradas nos índices, prevenindo-os de crescerem demasiadamente.*/

ALTER INDEX test_idx1 COALESCE;
