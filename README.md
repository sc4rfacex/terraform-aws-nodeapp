# Terraform - Infraestructura Multi-Tier con MongoDB
Este repositorio contiene código de Terraform para implementar una infraestructura multi-tier en la nube utilizando servicios de AWS. La infraestructura consta de tres instancias EC2:

### Instrucciones
- Contar con las variables de ambiente AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY para poder autentificarse hacia AWS.
- terraform plan -> verificar los recursos que se crearan
- terraform apply -auto-approve -> para empezar con la ejecucion y creacion de los recursos establecidos en main.tf
- terraform destroy -auto-approve -> para destruir los recursos generados en AWS una vez que ya no se ocupen.

### MongoDB:

Una instancia dedicada que actúa como servidor de la base de datos MongoDB.
Configuración de red segura para el acceso desde las instancias de aplicación.
Instancias de Aplicación (Node.js):

### NodeJS APP
Dos instancias que ejecutan aplicaciones Node.js conectadas a la instancia de MongoDB.
Configuración para autoescalado y balanceo de carga para garantizar alta disponibilidad y rendimiento.

### Componentes Incluidos:

**Load Balancers:**
Configuración de un balanceador de carga que distribuye el tráfico entre las instancias de aplicación.
**Listeners** y reglas para enrutar el tráfico correctamente a las instancias correspondientes.

**Network Interfaces:**
Interfaces de red para conectar las instancias a la red VPC.
Configuración de subredes públicas y privadas para garantizar la seguridad y la accesibilidad adecuada.

**Target Groups:**
Grupos de destino para definir las instancias que forman parte del conjunto equilibrado.
Reglas de salud para supervisar y mantener la disponibilidad de las instancias.
