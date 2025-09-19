# 💡 Data Pipeline ServiceNow + Hexagon com Airflow, dbt e BigQuery

Este projeto implementa um pipeline completo de dados unindo **ServiceNow → BigQuery → dbt → Airflow**, com anonimização e orquestração de fluxos ETL.  
O objetivo é construir um pipeline demonstrando boas práticas de integração, modelagem e automação de workflows de dados.
Passo a passo das execuções no [Gist](https://gist.github.com/cooorpse/62bffe6d1401dc768032095c5912baa8)

---

## Arquitetura do Projeto

1. **Extração & Anonimização (Python)**
   - Código Python realiza a request na API do **ServiceNow**.
   - Dados sensíveis são **anonimizados** com substituições radômicas (ex: `short_description`).
   - Código e passo a passo [aqui](https://gist.github.com/cooorpse/62bffe6d1401dc768032095c5912baa8)
   - Resultado é salvo e enviado para o **BigQuery** na camada **raw** (`dbt_servicenow.sn_incidents`).

   ![BigQuery](/assets/images/First Load BigQuery.png)

2. **Transformação (dbt)**
   - Utiliza **dbt** para organizar a camada de transformação:
     - **staging** → limpeza, normalização e aplicação de regras de negócio (ex.: tratamento de SLA, categorização via `CASE`).
     - **mart** → modelos finais prontos para análise (ex.: métricas de incidentes resolvidos dentro do SLA).
   - Estrutura de schemas/datasets:
     ```
     dbt_servicenow   → tabelas raw
     stg_servicenow   → tabelas staging
     mart_servicenow  → marts de negócio
     ```

3. **Orquestração (Airflow + Cosmos)**
   - Criação de DAGs com **Airflow Cosmos**:
     - `dbt_servicenow` → executa modelos ServiceNow.
     - `dbt_hexagon` → executa modelos Hexagon.
   - Cada DAG é desacoplado, pois os dois domínios não possuem dependências.

4. **Automação (API do Airflow)**
   - Além de schedules (`@daily`), DAGs podem ser disparadas via API:
   ```bash
    curl -X POST 'localhost:8080/api/v2/dags/dbt_servicenow/dagRuns' \
      --header 'Content-Type: application/json' \
      --data '{"logical_date": null}'
    ```

    ![Airflow](/assets/images/curl.gif)

---

## Tecnologias Utilizadas

- Python → requests + pandas para ingestão e anonimização
- Google BigQuery → camada raw e processamento analítico
- dbt Core → transformação de dados em staging e marts
- Airflow (Cosmos) → orquestração dos pipelines dbt
- Docker / Astro CLI → ambiente isolado para Airflow + dbt
