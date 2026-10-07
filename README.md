# LABORATORIO SEMANA 05

Para esta ocasión vamos a desplegar servicios de AWS usando Terraform y buenas prácticas

Este repositorio contiene el código de Infraestructura como Código para desplegar servicios de aws, tolerante a fallos y altamente disponible utilizando Terraform Workspaces para que se pueda desplegar en entornos dev, qa y prod.

## Flujo de Trabajo en Equipo 
1. **Ramas y PR:** Nadie escribe directamente en main. Cada entrega se hace mediante una rama propia y se debe abrir un Pull Request, para revisión del equipo.
2. **Validación:** Antes de subir un cambio, ejecuta de forma local:
   
   "terraform fmt" y "terraform validate"

3. **Despliegue Único:** Solo el Desplegador Oficial ejecuta terraform apply desde su máquina utilizando las credenciales de IAM Identity Center.

## Instrucciones de Despliegue de la Infraestructura
> Solo el **Desplegador Oficial** hace el despliegue.
 
### Clonar el repositorio y acceder a la carpeta
```bash
git clone https://github.com/anthonyepv-ctrl/IaC-Lab05-AWS-Lambda
cd IaC-Lab05-AWS-Lambda
```
 
### Instalar las librerías de las Lambdas
Esto se hace **antes** del despliegue, porque Terraform comprime las carpetas de `src/` tal como estén y `node_modules` no se sube al repositorio.
```bash
cd src/upload-lambda
npm install
```
```bash
cd ../crop-lambda
npm install --os=linux --cpu=x64 --libc=glibc sharp@0.33
```
```bash
cd ../..
```
`sharp` trae un archivo nativo y las Lambdas corren en Linux, por eso en `crop-lambda` se instala con esas banderas. No ejecutes después un `npm install` suelto en esa carpeta, porque puede cambiar ese archivo.
 
### Iniciar sesión en AWS
El perfil que se va a usar es el que tu creaste al configurar de IAM Identity Center usando AWS SSO, para este ejemplo usamos el profile de admin
```bash
aws sso login --profile admin
```
 
### Verificar que las credenciales funcionan
```bash
aws sts get-caller-identity --profile admin
```
 
### Inicializar
```bash
terraform init
```
 
### Crear workspaces (solo la primera vez)
```bash
terraform workspace new dev
```
```bash
terraform workspace new qa
```
```bash
terraform workspace new prod
```
 
### Seleccionar el entorno deseado (ejemplo: dev)
```bash
terraform workspace select dev
```
 
### Verificar que el workspace activo es el correcto
```bash
terraform workspace show
```
 
### Validar el código
```bash
terraform fmt -check
```
```bash
terraform validate
```
 
### Revisar el plan (opcional pero recomendable)
```bash
terraform plan
```
 
### Aplicar los cambios
```bash
terraform apply
```
Escribe `yes` cuando lo pida. Las Lambdas están dentro de una VPC y pueden tardar varios minutos en crearse, así que hay que esperar y no cortar el proceso.
 
Al final muestra el output `api_url`, que es la URL de la API para las pruebas.
 

 
### Destruir la infraestructura
Los NAT Gateways y el endpoint de SQS cobran por hora, así que destruimos todo al terminar las pruebas.
```bash
terraform destroy
```
 
---