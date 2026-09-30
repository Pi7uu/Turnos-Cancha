# tools/

Scripts standalone de mantenimiento.

## Reglas

- Un script por archivo, ejecutable con `python tools/<script>.py` desde `src/backend/`.
- No importar de `config` salvo lo estrictamente necesario; preferir `manage.py shell`.
