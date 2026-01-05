#!/bin/bash

# ============================================
# Draco Installer - Felix Studios
# Version: 2.2.0 - Fixed Daemon Flow
# ============================================

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variables globales
INSTALL_DIR="$PWD"
PANEL_PORT="3000"
DAEMON_PORT="3001"
FTP_PORT="3002"
SERVER_IP=""

# Función para obtener la IP del servidor
get_server_ip() {
    SERVER_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || hostname -I | awk '{print $1}' || echo "localhost")
}

# Función para mostrar el banner VISHUBI
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                ║"
    echo "║  ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗██████╗ ██╗                           ║"
    echo "║  ██║   ██║██║██╔════╝██║  ██║██║   ██║██╔══██╗██║                           ║"
    echo "║  ██║   ██║██║███████╗███████║██║   ██║██████╔╝██║                           ║"
    echo "║  ╚██╗ ██╔╝██║╚════██║██╔══██║██║   ██║██╔══██╗██║                           ║"
    echo "║   ╚████╔╝ ██║███████║██║  ██║╚██████╔╝██████╔╝███████╗                      ║"
    echo "║    ╚═══╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝                      ║"
    echo "║                                                                                ║"
    echo "║                     ${CYAN}Draco Panel & Daemon Installer${PURPLE}                    ║"
    echo "║                          ${YELLOW}Powered by Felix Studios${PURPLE}                     ║"
    echo "║                                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para mostrar el menú principal
show_main_menu() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                             ${WHITE}🎯 MENÚ PRINCIPAL ${CYAN}                            ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                                                ║${NC}"
    echo -e "${CYAN}║  ${GREEN}1. 🚀 Instalar Panel Draco                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}2. ⚙️  Instalar Daemon Draco                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${BLUE}3. 🔄 Reiniciar Servicios                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${BLUE}4. 📊 Ver Estado de Servicios                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${YELLOW}5. 🛠️  Configurar Daemon                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${RED}6. 🚪 Salir                                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}👉 Selecciona una opción [1-6]: ${NC}"
}

# Función para instalar PM2
install_pm2() {
    echo -e "${YELLOW}📦 Instalando PM2...${NC}"
    
    if command -v pm2 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PM2 ya está instalado${NC}"
        return 0
    fi
    
    if npm install -g pm2 --silent 2>/dev/null; then
        echo -e "${GREEN}✅ PM2 instalado correctamente${NC}"
        
        # Configurar PM2 para inicio automático
        echo -e "${YELLOW}⚙️  Configurando PM2 para inicio automático...${NC}"
        pm2 startup 2>/dev/null
        pm2 save 2>/dev/null
        
        return 0
    else
        echo -e "${RED}❌ Error instalando PM2${NC}"
        echo -e "${YELLOW}Intentando con sudo...${NC}"
        
        if sudo npm install -g pm2 --silent 2>/dev/null; then
            echo -e "${GREEN}✅ PM2 instalado con sudo${NC}"
            return 0
        else
            echo -e "${RED}❌ No se pudo instalar PM2${NC}"
            echo -e "${YELLOW}Puedes instalar PM2 manualmente después con:${NC}"
            echo -e "${BLUE}npm install -g pm2${NC}"
            return 1
        fi
    fi
}

# Función para verificar puerto
check_port() {
    local port=$1
    
    # Intentar con netstat
    if command -v netstat >/dev/null 2>&1; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    fi
    
    # Intentar con ss
    if command -v ss >/dev/null 2>&1; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    fi
    
    # Intentar con lsof
    if command -v lsof >/dev/null 2>&1; then
        if lsof -i :$port 2>/dev/null >/dev/null; then
            return 1
        fi
    fi
    
    return 0
}

# Función para crear usuario administrador manualmente
create_admin_user() {
    local panel_dir="$1"
    
    cd "$panel_dir" || return 1
    
    echo -e "${YELLOW}👤 Configurando usuario administrador...${NC}"
    
    # Crear credenciales por defecto
    cat > admin_credentials.txt << EOF
╔════════════════════════════════════════════════════════════════════════════════╗
║                         CREDENCIALES DE ADMINISTRADOR                          ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║   🔐 Usuario: admin                                                            ║
║   🔑 Contraseña: admin123                                                      ║
║   📧 Email: admin@draco.local                                                  ║
║                                                                                ║
║   ⚠️  IMPORTANTE: Cambia estas credenciales después del primer inicio de sesión ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
    
    echo -e "${GREEN}✅ Credenciales guardadas en admin_credentials.txt${NC}"
    
    # Si hay un script createUser, intentar ejecutarlo
    if [ -f "package.json" ] && grep -q "createUser" package.json; then
        echo -e "${YELLOW}Intentando crear usuario automáticamente...${NC}"
        npm run createUser 2>/dev/null || echo -e "${YELLOW}⚠️  Usando credenciales por defecto${NC}"
    fi
    
    cd "$INSTALL_DIR"
}

# Función para instalar el Panel
install_panel() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         ${WHITE}🚀 INSTALACIÓN DEL PANEL ${CYAN}                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar si ya está instalado
    if [ -d "v4panel" ]; then
        echo -e "${YELLOW}⚠️  El panel ya está instalado en: $INSTALL_DIR/v4panel${NC}"
        read -p "¿Deseas reinstalar? (s/N): " reinstall
        if [[ ! $reinstall =~ ^[Ss]$ ]]; then
            echo -e "${YELLOW}Instalación cancelada${NC}"
            return
        fi
        echo -e "${YELLOW}🗑️  Eliminando instalación anterior...${NC}"
        rm -rf v4panel
    fi
    
    # Actualizar sistema
    echo -e "${YELLOW}🔄 Actualizando sistema...${NC}"
    sudo apt-get update -y > /dev/null 2>&1
    
    # Instalar dependencias
    echo -e "${YELLOW}📦 Instalando dependencias del sistema...${NC}"
    sudo apt-get install -y curl git zip unzip > /dev/null 2>&1
    
    # Instalar Node.js
    echo -e "${YELLOW}⬇️  Instalando Node.js 23.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_23.x | sudo -E bash - > /dev/null 2>&1
    sudo apt-get install -y nodejs > /dev/null 2>&1
    
    # Clonar repositorio
    echo -e "${YELLOW}📥 Clonando repositorio del panel...${NC}"
    if git clone https://github.com/teryxlabs/v4panel.git; then
        echo -e "${GREEN}✅ Repositorio clonado correctamente${NC}"
    else
        echo -e "${RED}❌ Error al clonar el repositorio${NC}"
        return 1
    fi
    
    # Entrar al directorio
    cd v4panel || {
        echo -e "${RED}❌ Error al entrar al directorio${NC}"
        return 1
    }
    
    # Extraer panel.zip si existe
    if [ -f "panel.zip" ]; then
        echo -e "${YELLOW}📦 Extrayendo panel.zip...${NC}"
        unzip -o panel.zip > /dev/null 2>&1
    fi
    
    # Instalar dependencias de Node.js
    echo -e "${YELLOW}📦 Instalando dependencias de Node.js...${NC}"
    npm install --silent
    
    # Ejecutar seed si existe
    if [ -f "package.json" ] && grep -q "seed" package.json; then
        echo -e "${YELLOW}🌱 Configurando base de datos...${NC}"
        npm run seed 2>/dev/null || echo -e "${YELLOW}⚠️  Continuando con configuración manual${NC}"
    fi
    
    # Crear usuario administrador
    create_admin_user "$PWD"
    
    # Instalar PM2
    install_pm2
    
    # Verificar puerto
    echo -e "${YELLOW}🔍 Verificando puerto $PANEL_PORT...${NC}"
    if check_port $PANEL_PORT; then
        # Buscar archivo principal
        MAIN_FILE=""
        for file in "index.js" "app.js" "server.js" "main.js" "src/index.js"; do
            if [ -f "$file" ]; then
                MAIN_FILE="$file"
                break
            fi
        done
        
        if [ -n "$MAIN_FILE" ]; then
            # Iniciar panel con PM2
            echo -e "${YELLOW}🚀 Iniciando panel con PM2...${NC}"
            pm2 start $MAIN_FILE --name "draco-panel" --silent
            pm2 save --silent
            
            get_server_ip
            
            echo ""
            echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}                            ✅ INSTALACIÓN COMPLETADA                           ${NC}"
            echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${CYAN}📊 Panel Draco instalado y ejecutándose correctamente${NC}"
            echo ""
            echo -e "${WHITE}🌐 URLs de acceso:${NC}"
            echo -e "${BLUE}   • Local:    http://localhost:$PANEL_PORT${NC}"
            echo -e "${BLUE}   • Red:      http://$SERVER_IP:$PANEL_PORT${NC}"
            echo ""
            echo -e "${WHITE}👤 Credenciales por defecto:${NC}"
            echo -e "${YELLOW}   • Usuario:     admin${NC}"
            echo -e "${YELLOW}   • Contraseña:  admin123${NC}"
            echo -e "${YELLOW}   • Email:       admin@draco.local${NC}"
            echo ""
            echo -e "${WHITE}🔧 Comandos útiles:${NC}"
            echo -e "${YELLOW}   • Ver logs:        pm2 logs draco-panel${NC}"
            echo -e "${YELLOW}   • Reiniciar:       pm2 restart draco-panel${NC}"
            echo -e "${YELLOW}   • Detener:         pm2 stop draco-panel${NC}"
            echo -e "${YELLOW}   • Ver todos:       pm2 list${NC}"
            echo ""
            echo -e "${WHITE}⚠️  IMPORTANTE:${NC}"
            echo -e "${YELLOW}   • Las credenciales están en admin_credentials.txt${NC}"
            echo -e "${YELLOW}   • Cambia la contraseña después del primer acceso${NC}"
            echo ""
        else
            echo -e "${RED}❌ No se encontró archivo principal para iniciar${NC}"
            echo -e "${YELLOW}📁 Archivos buscados: index.js, app.js, server.js, main.js${NC}"
        fi
    else
        echo -e "${RED}❌ El puerto $PANEL_PORT está en uso${NC}"
        echo -e "${YELLOW}Por favor, libera el puerto o configura un puerto diferente${NC}"
    fi
    
    # Volver al directorio original
    cd "$INSTALL_DIR"
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para instalar el Daemon (FLUJO CORREGIDO)
install_daemon() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        ${WHITE}⚙️  INSTALACIÓN DEL DAEMON ${CYAN}                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Pedir configuración ANTES de instalar
    echo -e "${YELLOW}📝 Necesitamos configurar el daemon con tu panel:${NC}"
    echo ""
    
    read -p "URL del Panel (ej: https://pgc5tp-3000.csb.app): " panel_url
    read -p "Clave del Panel (ej: f773a79a-4059-4222-bca8-2bf17330872d): " panel_key
    
    if [ -z "$panel_url" ] || [ -z "$panel_key" ]; then
        echo -e "${RED}❌ Ambas credenciales son requeridas${NC}"
        return 1
    fi
    
    echo ""
    
    # Verificar si ya está instalado
    if [ -d "daemon" ]; then
        echo -e "${YELLOW}⚠️  El daemon ya está instalado en: $INSTALL_DIR/daemon${NC}"
        read -p "¿Deseas reinstalar? (s/N): " reinstall
        if [[ ! $reinstall =~ ^[Ss]$ ]]; then
            echo -e "${YELLOW}Instalación cancelada${NC}"
            return
        fi
        echo -e "${YELLOW}🗑️  Eliminando instalación anterior...${NC}"
        rm -rf daemon
    fi
    
    # Actualizar sistema
    echo -e "${YELLOW}🔄 Actualizando sistema...${NC}"
    sudo apt-get update -y > /dev/null 2>&1
    
    # Instalar dependencias
    echo -e "${YELLOW}📦 Instalando dependencias del sistema...${NC}"
    sudo apt-get install -y curl git zip unzip > /dev/null 2>&1
    
    # Clonar repositorio
    echo -e "${YELLOW}📥 Clonando repositorio del daemon...${NC}"
    if git clone https://github.com/teryxlabs/daemon.git; then
        echo -e "${GREEN}✅ Repositorio clonado correctamente${NC}"
    else
        echo -e "${RED}❌ Error al clonar el repositorio${NC}"
        return 1
    fi
    
    # Entrar al directorio
    cd daemon || {
        echo -e "${RED}❌ Error al entrar al directorio${NC}"
        return 1
    }
    
    # Extraer daemon.zip si existe
    if [ -f "daemon.zip" ]; then
        echo -e "${YELLOW}📦 Extrayendo daemon.zip...${NC}"
        unzip -o daemon.zip > /dev/null 2>&1
    fi
    
    # Entrar al subdirectorio daemon (si existe)
    if [ -d "daemon" ]; then
        echo -e "${YELLOW}📁 Entrando al subdirectorio daemon/...${NC}"
        cd daemon || {
            echo -e "${RED}❌ Error al entrar al subdirectorio${NC}"
            return 1
        }
    fi
    
    # Instalar dependencias de Node.js
    echo -e "${YELLOW}📦 Instalando dependencias de Node.js...${NC}"
    npm install --silent
    
    # CONFIGURAR ANTES DE INICIAR - PASO CRÍTICO
    echo -e "${YELLOW}🔧 Configurando daemon con el panel...${NC}"
    
    # Verificar si hay comando de configuración
    if [ -f "package.json" ] && grep -q "configure" package.json; then
        echo -e "${YELLOW}⚙️  Ejecutando comando de configuración...${NC}"
        echo -e "${BLUE}Comando: npm run configure -- --panel \"$panel_url\" --key \"$panel_key\"${NC}"
        
        if npm run configure -- --panel "$panel_url" --key "$panel_key" 2>/dev/null; then
            echo -e "${GREEN}✅ Configuración aplicada exitosamente${NC}"
        else
            echo -e "${YELLOW}⚠️  Creando configuración manualmente...${NC}"
            # Crear archivo de configuración manual
            cat > config.json << EOF
{
    "panel_url": "$panel_url",
    "panel_key": "$panel_key",
    "api": {
        "host": "0.0.0.0",
        "port": $DAEMON_PORT
    },
    "remoteKey": "$panel_key",
    "configured": true,
    "configured_at": "$(date)"
}
EOF
            echo -e "${GREEN}✅ Archivo config.json creado${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  No se encontró comando configure, creando configuración manual...${NC}"
        cat > config.json << EOF
{
    "panel": {
        "url": "$panel_url",
        "key": "$panel_key"
    },
    "api": {
        "host": "0.0.0.0",
        "port": $DAEMON_PORT,
        "ssl": false
    },
    "ftp": {
        "host": "0.0.0.0",
        "port": $FTP_PORT
    },
    "remoteKey": "$panel_key",
    "configured": true,
    "configured_at": "$(date)"
}
EOF
        echo -e "${GREEN}✅ Configuración creada manualmente${NC}"
    fi
    
    # Instalar PM2
    install_pm2
    
    # AHORA INICIAR EL DAEMON - DESPUÉS DE CONFIGURAR
    echo -e "${YELLOW}🚀 Iniciando daemon Draco...${NC}"
    
    # Buscar archivo principal
    MAIN_FILE=""
    for file in "index.js" "app.js" "server.js" "main.js" "src/index.js"; do
        if [ -f "$file" ]; then
            MAIN_FILE="$file"
            break
        fi
    done
    
    if [ -n "$MAIN_FILE" ]; then
        # Iniciar con PM2
        pm2 start $MAIN_FILE --name "draco-daemon" --silent
        pm2 save --silent
        
        # Esperar unos segundos para que se inicie
        sleep 3
        
        get_server_ip
        
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}                            ✅ INSTALACIÓN COMPLETADA                           ${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${CYAN}⚙️  Daemon Draco instalado y configurado correctamente${NC}"
        echo ""
        echo -e "${WHITE}🌐 URLs de acceso:${NC}"
        echo -e "${BLUE}   • API: http://$SERVER_IP:$DAEMON_PORT${NC}"
        echo -e "${BLUE}   • FTP: ftp://$SERVER_IP:$FTP_PORT${NC}"
        echo ""
        echo -e "${WHITE}🔧 Configuración aplicada:${NC}"
        echo -e "${YELLOW}   • Panel URL: $panel_url${NC}"
        echo -e "${YELLOW}   • Panel Key: $panel_key${NC}"
        echo ""
        echo -e "${WHITE}🔧 Comandos útiles:${NC}"
        echo -e "${YELLOW}   • Ver logs:        pm2 logs draco-daemon${NC}"
        echo -e "${YELLOW}   • Reiniciar:       pm2 restart draco-daemon${NC}"
        echo -e "${YELLOW}   • Detener:         pm2 stop draco-daemon${NC}"
        echo -e "${YELLOW}   • Ver estado:      pm2 status${NC}"
        echo ""
        echo -e "${WHITE}⚠️  NOTA:${NC}"
        echo -e "${YELLOW}   • El daemon ya está configurado y corriendo${NC}"
        echo -e "${YELLOW}   • No es necesario ejecutar node . manualmente${NC}"
        echo ""
    else
        echo -e "${RED}❌ No se encontró archivo principal para iniciar${NC}"
        echo -e "${YELLOW}💡 Puedes iniciar manualmente con: cd daemon && node .${NC}"
    fi
    
    # Volver al directorio original
    cd "$INSTALL_DIR"
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para configurar daemon existente (FLUJO CORREGIDO)
configure_daemon() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        ${WHITE}🔧 CONFIGURAR DAEMON EXISTENTE ${CYAN}                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "daemon" ]; then
        echo -e "${RED}❌ No se encontró instalación del daemon${NC}"
        echo -e "${YELLOW}Primero instala el daemon con la opción 2${NC}"
        return 1
    fi
    
    cd daemon || {
        echo -e "${RED}❌ Error al entrar al directorio${NC}"
        return 1
    }
    
    if [ -d "daemon" ]; then
        cd daemon || {
            echo -e "${RED}❌ Error al entrar al subdirectorio${NC}"
            return 1
        }
    fi
    
    echo -e "${WHITE}📝 Configuración del daemon Draco${NC}"
    echo ""
    
    # Pedir nueva configuración
    echo -e "${YELLOW}Ingresa los nuevos datos de configuración:${NC}"
    echo ""
    
    read -p "URL del Panel (ej: https://pgc5tp-3000.csb.app): " panel_url
    read -p "Clave del Panel (ej: f773a79a-4059-4222-bca8-2bf17330872d): " panel_key
    
    if [ -z "$panel_url" ] || [ -z "$panel_key" ]; then
        echo -e "${RED}❌ Ambas credenciales son requeridas${NC}"
        cd "$INSTALL_DIR"
        return 1
    fi
    
    # Detener daemon si está corriendo
    if pm2 list | grep -q "draco-daemon"; then
        echo -e "${YELLOW}⏸️  Deteniendo daemon...${NC}"
        pm2 stop draco-daemon --silent
    fi
    
    # Configurar ANTES de reiniciar
    echo -e "${YELLOW}🔧 Aplicando nueva configuración...${NC}"
    
    if [ -f "package.json" ] && grep -q "configure" package.json; then
        echo -e "${YELLOW}⚙️  Ejecutando comando de configuración...${NC}"
        
        if npm run configure -- --panel "$panel_url" --key "$panel_key" 2>/dev/null; then
            echo -e "${GREEN}✅ Configuración aplicada exitosamente${NC}"
        else
            echo -e "${YELLOW}⚠️  Actualizando configuración manualmente...${NC}"
            # Actualizar config.json manualmente
            if [ -f "config.json" ]; then
                sed -i "s|\"url\": \".*\"|\"url\": \"$panel_url\"|" config.json
                sed -i "s|\"key\": \".*\"|\"key\": \"$panel_key\"|" config.json
                sed -i "s|\"remoteKey\": \".*\"|\"remoteKey\": \"$panel_key\"|" config.json
            else
                cat > config.json << EOF
{
    "panel_url": "$panel_url",
    "panel_key": "$panel_key",
    "api": {
        "host": "0.0.0.0",
        "port": $DAEMON_PORT
    },
    "remoteKey": "$panel_key"
}
EOF
            fi
            echo -e "${GREEN}✅ Configuración actualizada manualmente${NC}"
        fi
    else
        echo -e "${YELLOW}📝 Actualizando archivo de configuración...${NC}"
        if [ -f "config.json" ]; then
            sed -i "s|\"url\": \".*\"|\"url\": \"$panel_url\"|" config.json
            sed -i "s|\"key\": \".*\"|\"key\": \"$panel_key\"|" config.json
            sed -i "s|\"remoteKey\": \".*\"|\"remoteKey\": \"$panel_key\"|" config.json
        else
            cat > config.json << EOF
{
    "panel": {
        "url": "$panel_url",
        "key": "$panel_key"
    },
    "api": {
        "host": "0.0.0.0",
        "port": $DAEMON_PORT,
        "ssl": false
    },
    "ftp": {
        "host": "0.0.0.0",
        "port": $FTP_PORT
    },
    "remoteKey": "$panel_key"
}
EOF
        fi
        echo -e "${GREEN}✅ Configuración actualizada${NC}"
    fi
    
    # AHORA REINICIAR EL DAEMON - DESPUÉS DE CONFIGURAR
    echo -e "${YELLOW}🔄 Reiniciando daemon con nueva configuración...${NC}"
    
    if pm2 list | grep -q "draco-daemon"; then
        pm2 restart draco-daemon --silent
    else
        # Buscar archivo principal
        MAIN_FILE=""
        for file in "index.js" "app.js" "server.js" "main.js" "src/index.js"; do
            if [ -f "$file" ]; then
                MAIN_FILE="$file"
                break
            fi
        done
        
        if [ -n "$MAIN_FILE" ]; then
            pm2 start $MAIN_FILE --name "draco-daemon" --silent
            pm2 save --silent
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✅ Daemon configurado y reiniciado${NC}"
    echo -e "${CYAN}📋 Nueva configuración:${NC}"
    echo -e "${YELLOW}   • Panel URL: $panel_url${NC}"
    echo -e "${YELLOW}   • Panel Key: $panel_key${NC}"
    echo ""
    echo -e "${WHITE}🔧 El daemon ya está corriendo con la nueva configuración${NC}"
    
    cd "$INSTALL_DIR"
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para reiniciar servicios
restart_services() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         ${WHITE}🔄 REINICIAR SERVICIOS ${CYAN}                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if ! command -v pm2 >/dev/null 2>&1; then
        echo -e "${RED}❌ PM2 no está instalado${NC}"
        return 1
    fi
    
    echo -e "${WHITE}Selecciona qué servicios reiniciar:${NC}"
    echo ""
    echo -e "${GREEN}1. 🔄 Reiniciar Panel Draco${NC}"
    echo -e "${GREEN}2. ⚙️  Reiniciar Daemon Draco${NC}"
    echo -e "${GREEN}3. 🔄 Reiniciar Ambos${NC}"
    echo -e "${YELLOW}4. ↩️  Volver${NC}"
    echo ""
    echo -e "${WHITE}Opción [1-4]: ${NC}"
    read restart_choice
    
    case $restart_choice in
        1)
            if pm2 list | grep -q "draco-panel"; then
                echo -e "${YELLOW}🔄 Reiniciando Panel Draco...${NC}"
                pm2 restart draco-panel --silent
                echo -e "${GREEN}✅ Panel reiniciado${NC}"
            else
                echo -e "${RED}❌ Panel Draco no está corriendo${NC}"
            fi
            ;;
        2)
            if pm2 list | grep -q "draco-daemon"; then
                echo -e "${YELLOW}🔄 Reiniciando Daemon Draco...${NC}"
                pm2 restart draco-daemon --silent
                echo -e "${GREEN}✅ Daemon reiniciado${NC}"
            else
                echo -e "${RED}❌ Daemon Draco no está corriendo${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}🔄 Reiniciando todos los servicios...${NC}"
            pm2 restart all --silent
            echo -e "${GREEN}✅ Todos los servicios reiniciados${NC}"
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para ver estado de servicios
show_status() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         ${WHITE}📊 ESTADO DE SERVICIOS ${CYAN}                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    get_server_ip
    
    echo -e "${WHITE}🌐 Información del Servidor:${NC}"
    echo -e "${BLUE}   • IP Pública:  $SERVER_IP${NC}"
    echo -e "${BLUE}   • Directorio:  $INSTALL_DIR${NC}"
    echo ""
    
    # Verificar PM2
    if command -v pm2 >/dev/null 2>&1; then
        echo -e "${WHITE}📦 Servicios PM2:${NC}"
        echo ""
        
        # Panel status
        if pm2 list | grep -q "draco-panel"; then
            echo -e "${GREEN}   ✅ Panel Draco:      CORRIENDO${NC}"
            echo -e "${BLUE}      URL: http://$SERVER_IP:$PANEL_PORT${NC}"
        else
            echo -e "${RED}   ❌ Panel Draco:      DETENIDO${NC}"
        fi
        
        # Daemon status
        if pm2 list | grep -q "draco-daemon"; then
            echo -e "${GREEN}   ✅ Daemon Draco:     CORRIENDO${NC}"
            echo -e "${BLUE}      URL: http://$SERVER_IP:$DAEMON_PORT${NC}"
        else
            echo -e "${RED}   ❌ Daemon Draco:     DETENIDO${NC}"
        fi
        
        echo ""
        echo -e "${WHITE}📊 Resumen PM2:${NC}"
        pm2 list --no-color | head -10
        
    else
        echo -e "${YELLOW}⚠️  PM2 no está instalado${NC}"
        echo -e "${YELLOW}Los servicios podrían no estar corriendo como daemon${NC}"
    fi
    
    echo ""
    
    # Verificar directorios
    echo -e "${WHITE}📁 Instalaciones detectadas:${NC}"
    if [ -d "v4panel" ]; then
        echo -e "${GREEN}   ✅ Panel instalado en: v4panel/${NC}"
    else
        echo -e "${YELLOW}   📭 Panel no instalado${NC}"
    fi
    
    if [ -d "daemon" ]; then
        echo -e "${GREEN}   ✅ Daemon instalado en: daemon/${NC}"
        if [ -d "daemon/daemon" ]; then
            echo -e "${BLUE}      Subdirectorio: daemon/daemon/${NC}"
        fi
    else
        echo -e "${YELLOW}   📭 Daemon no instalado${NC}"
    fi
    
    echo ""
    echo -e "${WHITE}🔧 Comandos útiles:${NC}"
    echo -e "${YELLOW}   • Ver logs panel:    pm2 logs draco-panel${NC}"
    echo -e "${YELLOW}   • Ver logs daemon:   pm2 logs draco-daemon${NC}"
    echo -e "${YELLOW}   • Monitorear:        pm2 monit${NC}"
    echo -e "${YELLOW}   • Reiniciar todo:    pm2 restart all${NC}"
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función principal
main() {
    # Verificar root
    if [ "$EUID" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Ejecutando como root. Continuando...${NC}"
    else
        echo -e "${YELLOW}⚠️  Algunos comandos requieren sudo.${NC}"
        echo -e "${YELLOW}   Se te pedirá contraseña si es necesario.${NC}"
        echo ""
    fi
    
    while true; do
        show_banner
        show_main_menu
        
        read choice
        
        case $choice in
            1)
                install_panel
                ;;
            2)
                install_daemon
                ;;
            3)
                restart_services
                ;;
            4)
                show_status
                ;;
            5)
                configure_daemon
                ;;
            6)
                echo ""
                echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo -e "${GREEN}                    🎉 Gracias por usar Draco Installer                    ${NC}"
                echo -e "${GREEN}                         Powered by Felix Studios                          ${NC}"
                echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida. Presiona Enter para continuar...${NC}"
                read
                ;;
        esac
    done
}

# Capturar Ctrl+C
trap 'echo -e "\n${YELLOW}👋 Saliendo del instalador...${NC}"; exit 0' INT

# Iniciar
main
