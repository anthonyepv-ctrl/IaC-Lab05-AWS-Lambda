# LABORATORIO SEMANA 05

Para esta ocasión vamos a desplegar servicios de AWS usando Terraform y buenas prácticas

Este repositorio contiene el código de Infraestructura como Código para desplegar servicios de aws, tolerante a fallos y altamente disponible utilizando Terraform Workspaces para que se pueda desplegar en entornos dev, qa y prod.

## Flujo de Trabajo en Equipo 
1. **Ramas y PR:** Nadie escribe directamente en main. Cada entrega se hace mediante una rama propia y se debe abrir un Pull Request, para revisión del equipo.
2. **Validación:** Antes de subir un cambio, ejecuta de forma local:
   
   "terraform fmt" y "terraform validate"

3. **Despliegue Único:** Solo el Desplegador Oficial ejecuta terraform apply desde su máquina utilizando las credenciales de IAM Identity Center.

## Instrucciones de Despliegue de la Infraestructura