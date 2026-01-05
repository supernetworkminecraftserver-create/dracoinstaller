#!/bin/bash

# ============================================
# Draco Control System - Felix Studios
# Version: 3.0.0 - GitHub Edition
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
PANEL_URL=""
PANEL_KEY=""
ADMIN_USER="admin"
ADMIN_PASS="admin123"
ADMIN_EMAIL="admin@draco.local"

# Función para obtener la IP del servidor
get_server_ip() {
    SERVER_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || hostname -I | awk '{print $1}' || echo "localhost")
}

# Función para mostrar el banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                ║"
    echo "║  ██████╗ ██████╗  █████╗  ██████╗ ██████╗      ██████╗██████╗ ███████╗██████╗  ║"
    echo "║  ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔═══██╗    ██╔════╝██╔══██╗██╔════╝██╔══██╗ ║"
    echo "║  ██║  ██║██████╔╝███████║██║     ██║   ██║    ██║     ██████╔╝█████╗  ██████╔╝ ║"
    echo "║  ██║  ██║██╔══██╗██╔══██║██║     ██║   ██║    ██║     ██╔══██╗██╔══╝  ██╔══██╗ ║"
    echo "║  ██████╔╝██║  ██║██║  ██║╚██████╗╚██████╔╝    ╚██████╗██║  ██║███████╗██║  ██║ ║"
    echo "║  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ║"
    echo "║                                                                                ║"
    echo "║                     ${CYAN}D R A C O   C O N T R O L   S Y S T E M${PURPLE}                    ║"
    echo "║                           ${YELLOW}Powered by Felix Studios${PURPLE}                           ║"
    echo "║                                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para mostrar el menú principal
show_main_menu() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                               ${WHITE}🎯 MAIN MENU${CYAN}                                  ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                                                ║${NC}"
    echo -e "${CYAN}║  ${GREEN}1. 🚀 Install Draco Panel                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}2. ⚙️  Install Draco Daemon                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${BLUE}3. 🔧 Configure Daemon                                             ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${BLUE}4. 🔄 Manage Services                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${YELLOW}5. 📊 System Status                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${RED}6. 🚪 Exit                                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Select an option [1-6]: ${NC}"
}

# Función para verificar y actualizar el sistema
update_system() {
    echo -e "${YELLOW}🔄 Updating system packages...${NC}"
    sudo apt-get update -y > /dev/null 2>&1
    echo -e "${GREEN}✅ System updated${NC}"
}

# Función para instalar dependencias básicas
install_basic_deps() {
    echo -e "${YELLOW}📦 Installing basic dependencies...${NC}"
    
    # Lista de dependencias esenciales
    local deps=(
        "curl"
        "git"
        "wget"
        "build-essential"
        "libssl-dev"
        "unzip"
        "zip"
        "sudo"
    )
    
    for dep in "${deps[@]}"; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo -e "${YELLOW}  Installing $dep...${NC}"
            sudo apt-get install -y $dep > /dev/null 2>&1
        fi
    done
    
    echo -e "${GREEN}✅ Basic dependencies installed${NC}"
}

# Función para instalar Node.js 23.x
install_nodejs() {
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        echo -e "${GREEN}✅ Node.js $NODE_VERSION already installed${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}⬇️ Installing Node.js 23.x...${NC}"
    
    # Instalar Node.js desde NodeSource
    curl -fsSL https://deb.nodesource.com/setup_23.x | sudo -E bash - > /dev/null 2>&1
    sudo apt-get install -y nodejs > /dev/null 2>&1
    
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✅ $NODE_VERSION installed${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to install Node.js${NC}"
        return 1
    fi
}

# Función para instalar PM2
install_pm2() {
    if command -v pm2 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PM2 already installed${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}📦 Installing PM2 process manager...${NC}"
    
    # Instalar PM2 globalmente
    sudo npm install -g pm2 > /dev/null 2>&1
    
    if command -v pm2 >/dev/null 2>&1; then
        # Configurar PM2 para inicio automático
        echo -e "${YELLOW}⚙️ Setting up PM2 startup...${NC}"
        pm2 startup > /dev/null 2>&1
        echo -e "${GREEN}✅ PM2 installed and configured${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to install PM2${NC}"
        return 1
    fi
}

# Función para crear usuario administrador manualmente
create_admin_user() {
    local panel_dir="$1"
    
    echo -e "${YELLOW}👤 Creating admin user...${NC}"
    
    cd "$panel_dir" || return 1
    
    # Verificar si hay un script de creación de usuario
    if [ -f "package.json" ] && grep -q "createUser" package.json; then
        echo -e "${YELLOW}  Running createUser script...${NC}"
        npm run createUser 2>/dev/null || {
            echo -e "${YELLOW}  createUser script failed, creating manually...${NC}"
        }
    fi
    
    # Intentar crear usuario manualmente
    echo -e "${YELLOW}  Setting up admin credentials...${NC}"
    
    # Crear archivo de configuración de usuario si existe la estructura
    if [ -d "config" ]; then
        cat > config/admin.json << EOF
{
    "username": "$ADMIN_USER",
    "password": "$ADMIN_PASS",
    "email": "$ADMIN_EMAIL",
    "admin": true,
    "createdAt": "$(date -Iseconds)"
}
EOF
        echo -e "${GREEN}  ✅ Admin configuration created${NC}"
    fi
    
    # Mostrar credenciales
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                          ADMIN CREDENTIALS                                    ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}👤 Username: ${GREEN}$ADMIN_USER${NC}"
    echo -e "${WHITE}🔑 Password: ${GREEN}$ADMIN_PASS${NC}"
    echo -e "${WHITE}📧 Email:    ${GREEN}$ADMIN_EMAIL${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Change these credentials after first login!${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    cd "$INSTALL_DIR"
}

# Función para verificar puerto
check_port() {
    local port=$1
    
    # Usar netstat si está disponible
    if command -v netstat >/dev/null 2>&1; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    fi
    
    # Usar ss si está disponible
    if command -v ss >/dev/null 2>&1; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    fi
    
    # Intentar conectar al puerto
    if timeout 1 bash -c "echo > /dev/tcp/localhost/$port" 2>/dev/null; then
        return 1
    fi
    
    return 0
}

# Función para instalar el Panel
install_panel() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          ${WHITE}🚀 INSTALLING DRACO PANEL${CYAN}                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar si ya está instalado
    if [ -d "v4panel" ]; then
        echo -e "${YELLOW}⚠️ Panel already installed at: $INSTALL_DIR/v4panel${NC}"
        read -p "Reinstall? (y/N): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            return
        fi
        echo -e "${YELLOW}🗑️ Removing previous installation...${NC}"
        rm -rf v4panel
    fi
    
    # Actualizar sistema
    update_system
    
    # Instalar dependencias básicas
    install_basic_deps
    
    # Instalar Node.js
    if ! install_nodejs; then
        echo -e "${RED}❌ Node.js installation failed${NC}"
        return 1
    fi
    
    # Clonar repositorio del panel
    echo -e "${YELLOW}📥 Cloning panel repository...${NC}"
    if git clone https://github.com/teryxlabs/v4panel.git; then
        echo -e "${GREEN}✅ Repository cloned${NC}"
    else
        echo -e "${RED}❌ Failed to clone repository${NC}"
        return 1
    fi
    
    cd v4panel || {
        echo -e "${RED}❌ Failed to enter panel directory${NC}"
        return 1
    }
    
    # Extraer panel.zip si existe
    if [ -f "panel.zip" ]; then
        echo -e "${YELLOW}📦 Extracting panel.zip...${NC}"
        unzip -o panel.zip > /dev/null 2>&1
    fi
    
    # Instalar dependencias de Node.js
    echo -e "${YELLOW}📦 Installing Node.js dependencies...${NC}"
    npm install --silent
    
    # Ejecutar seed si existe
    if [ -f "package.json" ] && grep -q "seed" package.json; then
        echo -e "${YELLOW}🌱 Running database seed...${NC}"
        npm run seed 2>/dev/null || echo -e "${YELLOW}⚠️ Seed command may have issues${NC}"
    fi
    
    # Crear usuario administrador
    create_admin_user "$PWD"
    
    # Instalar PM2
    install_pm2
    
    # Verificar puerto
    echo -e "${YELLOW}🔍 Checking port $PANEL_PORT...${NC}"
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
            echo -e "${YELLOW}🚀 Starting panel with PM2...${NC}"
            pm2 start $MAIN_FILE --name "draco-panel" --silent
            pm2 save --silent
            
            get_server_ip
            
            echo ""
            echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}                            ✅ PANEL INSTALLATION COMPLETE                          ${NC}"
            echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${CYAN}🌐 Panel Access URLs:${NC}"
            echo -e "${BLUE}   • Local:    http://localhost:$PANEL_PORT${NC}"
            echo -e "${BLUE}   • Network:  http://$SERVER_IP:$PANEL_PORT${NC}"
            echo ""
            echo -e "${CYAN}👤 Admin Credentials:${NC}"
            echo -e "${WHITE}   • Username: ${GREEN}$ADMIN_USER${NC}"
            echo -e "${WHITE}   • Password: ${GREEN}$ADMIN_PASS${NC}"
            echo ""
            echo -e "${CYAN}🔧 PM2 Commands:${NC}"
            echo -e "${YELLOW}   • View logs:     pm2 logs draco-panel${NC}"
            echo -e "${YELLOW}   • Restart:       pm2 restart draco-panel${NC}"
            echo -e "${YELLOW}   • Status:        pm2 status${NC}"
            echo ""
        else
            echo -e "${RED}❌ No main file found to start${NC}"
        fi
    else
        echo -e "${RED}❌ Port $PANEL_PORT is already in use${NC}"
        echo -e "${YELLOW}Try changing the port in panel configuration${NC}"
    fi
    
    cd "$INSTALL_DIR"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Función para instalar el Daemon
install_daemon() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         ${WHITE}⚙️ INSTALLING DRACO DAEMON${CYAN}                       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Pedir configuración del panel
    echo -e "${YELLOW}📝 Panel Configuration Needed:${NC}"
    echo ""
    
    read -p "Panel URL (e.g., http://your-server.com:3000): " PANEL_URL
    read -p "Panel Access Key (from panel config.json): " PANEL_KEY
    
    if [ -z "$PANEL_URL" ] || [ -z "$PANEL_KEY" ]; then
        echo -e "${RED}❌ Both URL and Key are required${NC}"
        return 1
    fi
    
    # Verificar si ya está instalado
    if [ -d "daemon" ]; then
        echo -e "${YELLOW}⚠️ Daemon already installed at: $INSTALL_DIR/daemon${NC}"
        read -p "Reinstall? (y/N): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            return
        fi
        echo -e "${YELLOW}🗑️ Removing previous installation...${NC}"
        rm -rf daemon
    fi
    
    # Actualizar sistema
    update_system
    
    # Instalar dependencias básicas
    install_basic_deps
    
    # Instalar Node.js
    if ! install_nodejs; then
        echo -e "${RED}❌ Node.js installation failed${NC}"
        return 1
    fi
    
    # Clonar repositorio del daemon
    echo -e "${YELLOW}📥 Cloning daemon repository...${NC}"
    if git clone https://github.com/teryxlabs/daemon.git; then
        echo -e "${GREEN}✅ Repository cloned${NC}"
    else
        echo -e "${RED}❌ Failed to clone repository${NC}"
        return 1
    fi
    
    cd daemon || {
        echo -e "${RED}❌ Failed to enter daemon directory${NC}"
        return 1
    }
    
    # Entrar al subdirectorio si existe
    if [ -d "daemon" ]; then
        echo -e "${YELLOW}📁 Entering daemon/daemon subdirectory...${NC}"
        cd daemon || {
            echo -e "${RED}❌ Failed to enter subdirectory${NC}"
            return 1
        }
    fi
    
    # Extraer daemon.zip si existe
    if [ -f "daemon.zip" ]; then
        echo -e "${YELLOW}📦 Extracting daemon.zip...${NC}"
        unzip -o daemon.zip > /dev/null 2>&1
    fi
    
    # Instalar dependencias de Node.js
    echo -e "${YELLOW}📦 Installing Node.js dependencies...${NC}"
    npm install --silent
    
    # Configurar el daemon
    echo -e "${YELLOW}🔧 Configuring daemon...${NC}"
    
    # Crear o actualizar config.json
    cat > config.json << EOF
{
    "api": {
        "host": "0.0.0.0",
        "port": $DAEMON_PORT,
        "ssl": false
    },
    "ftp": {
        "host": "0.0.0.0",
        "port": $FTP_PORT
    },
    "panel": {
        "url": "$PANEL_URL",
        "key": "$PANEL_KEY"
    },
    "remoteKey": "$PANEL_KEY",
    "configured": true,
    "configured_at": "$(date)"
}
EOF
    
    echo -e "${GREEN}✅ Configuration file created${NC}"
    
    # Ejecutar comando de configuración si existe
    if [ -f "package.json" ] && grep -q "configure" package.json; then
        echo -e "${YELLOW}⚙️ Running configuration command...${NC}"
        npm run configure -- --panel "$PANEL_URL" --key "$PANEL_KEY" 2>/dev/null || \
            echo -e "${YELLOW}⚠️ Configuration command may have issues${NC}"
    fi
    
    # Instalar PM2
    install_pm2
    
    # Verificar puertos
    echo -e "${YELLOW}🔍 Checking ports...${NC}"
    
    PORT_CHANGED=false
    ORIGINAL_DAEMON_PORT=$DAEMON_PORT
    ORIGINAL_FTP_PORT=$FTP_PORT
    
    # Verificar puerto daemon
    if ! check_port $DAEMON_PORT; then
        echo -e "${YELLOW}⚠️ Port $DAEMON_PORT in use, trying $((DAEMON_PORT+1))...${NC}"
        DAEMON_PORT=$((DAEMON_PORT+1))
        PORT_CHANGED=true
    fi
    
    # Verificar puerto FTP
    if ! check_port $FTP_PORT; then
        echo -e "${YELLOW}⚠️ Port $FTP_PORT in use, trying $((FTP_PORT+1))...${NC}"
        FTP_PORT=$((FTP_PORT+1))
        PORT_CHANGED=true
    fi
    
    # Actualizar configuración si los puertos cambiaron
    if [ "$PORT_CHANGED" = true ]; then
        echo -e "${YELLOW}🔄 Updating configuration with new ports...${NC}"
        sed -i "s/\"port\": $ORIGINAL_DAEMON_PORT/\"port\": $DAEMON_PORT/" config.json
        sed -i "s/\"port\": $ORIGINAL_FTP_PORT/\"port\": $FTP_PORT/" config.json
    fi
    
    # Buscar archivo principal
    MAIN_FILE=""
    for file in "index.js" "app.js" "server.js" "main.js" "src/index.js"; do
        if [ -f "$file" ]; then
            MAIN_FILE="$file"
            break
        fi
    done
    
    if [ -n "$MAIN_FILE" ]; then
        # Iniciar daemon con PM2
        echo -e "${YELLOW}🚀 Starting daemon with PM2...${NC}"
        pm2 start $MAIN_FILE --name "draco-daemon" --silent
        pm2 save --silent
        
        get_server_ip
        
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}                            ✅ DAEMON INSTALLATION COMPLETE                        ${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${CYAN}🌐 Daemon Access URLs:${NC}"
        echo -e "${BLUE}   • API: http://$SERVER_IP:$DAEMON_PORT${NC}"
        echo -e "${BLUE}   • FTP: ftp://$SERVER_IP:$FTP_PORT${NC}"
        echo ""
        echo -e "${CYAN}🔧 Configuration:${NC}"
        echo -e "${WHITE}   • Panel URL: ${GREEN}$PANEL_URL${NC}"
        echo -e "${WHITE}   • Panel Key: ${GREEN}$PANEL_KEY${NC}"
        echo ""
        if [ "$PORT_CHANGED" = true ]; then
            echo -e "${YELLOW}⚠️ Ports were changed due to conflicts:${NC}"
            if [ "$ORIGINAL_DAEMON_PORT" != "$DAEMON_PORT" ]; then
                echo -e "${WHITE}   • Daemon API: ${ORIGINAL_DAEMON_PORT} → ${GREEN}$DAEMON_PORT${NC}"
            fi
            if [ "$ORIGINAL_FTP_PORT" != "$FTP_PORT" ]; then
                echo -e "${WHITE}   • FTP: ${ORIGINAL_FTP_PORT} → ${GREEN}$FTP_PORT${NC}"
            fi
            echo ""
        fi
        echo -e "${CYAN}🔧 PM2 Commands:${NC}"
        echo -e "${YELLOW}   • View logs:     pm2 logs draco-daemon${NC}"
        echo -e "${YELLOW}   • Restart:       pm2 restart draco-daemon${NC}"
        echo -e "${YELLOW}   • Status:        pm2 status${NC}"
        echo ""
    else
        echo -e "${RED}❌ No main file found to start${NC}"
    fi
    
    cd "$INSTALL_DIR"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Función para configurar daemon existente
configure_daemon() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          ${WHITE}🔧 CONFIGURE DAEMON${CYAN}                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "daemon" ]; then
        echo -e "${RED}❌ Daemon not installed. Please install it first.${NC}"
        return 1
    fi
    
    # Pedir nueva configuración
    echo -e "${YELLOW}📝 Enter new configuration:${NC}"
    echo ""
    
    read -p "Panel URL: " NEW_PANEL_URL
    read -p "Panel Key: " NEW_PANEL_KEY
    
    if [ -z "$NEW_PANEL_URL" ] || [ -z "$NEW_PANEL_KEY" ]; then
        echo -e "${RED}❌ Both URL and Key are required${NC}"
        return 1
    fi
    
    cd daemon || return 1
    
    # Entrar al subdirectorio si existe
    if [ -d "daemon" ]; then
        cd daemon || return 1
    fi
    
    # Detener daemon si está corriendo
    if pm2 list | grep -q "draco-daemon"; then
        echo -e "${YELLOW}⏸️ Stopping daemon...${NC}"
        pm2 stop draco-daemon --silent
    fi
    
    # Actualizar configuración
    echo -e "${YELLOW}⚙️ Updating configuration...${NC}"
    
    if [ -f "config.json" ]; then
        # Actualizar config.json existente
        sed -i "s|\"url\": \".*\"|\"url\": \"$NEW_PANEL_URL\"|" config.json
        sed -i "s|\"key\": \".*\"|\"key\": \"$NEW_PANEL_KEY\"|" config.json
        sed -i "s|\"remoteKey\": \".*\"|\"remoteKey\": \"$NEW_PANEL_KEY\"|" config.json
    else
        # Crear nuevo config.json
        cat > config.json << EOF
{
    "api": {
        "host": "0.0.0.0",
        "port": $DAEMON_PORT,
        "ssl": false
    },
    "ftp": {
        "host": "0.0.0.0",
        "port": $FTP_PORT
    },
    "panel": {
        "url": "$NEW_PANEL_URL",
        "key": "$NEW_PANEL_KEY"
    },
    "remoteKey": "$NEW_PANEL_KEY"
}
EOF
    fi
    
    # Ejecutar comando de configuración si existe
    if [ -f "package.json" ] && grep -q "configure" package.json; then
        echo -e "${YELLOW}🔧 Running configuration...${NC}"
        npm run configure -- --panel "$NEW_PANEL_URL" --key "$NEW_PANEL_KEY" 2>/dev/null || \
            echo -e "${YELLOW}⚠️ Using manual configuration${NC}"
    fi
    
    # Reiniciar daemon
    echo -e "${YELLOW}🔄 Restarting daemon...${NC}"
    
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
    
    echo -e "${GREEN}✅ Daemon configured and restarted${NC}"
    echo ""
    echo -e "${CYAN}📋 New Configuration:${NC}"
    echo -e "${WHITE}   • Panel URL: ${GREEN}$NEW_PANEL_URL${NC}"
    echo -e "${WHITE}   • Panel Key: ${GREEN}$NEW_PANEL_KEY${NC}"
    
    cd "$INSTALL_DIR"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Función para gestionar servicios
manage_services() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          ${WHITE}🔄 MANAGE SERVICES${CYAN}                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if ! command -v pm2 >/dev/null 2>&1; then
        echo -e "${RED}❌ PM2 is not installed${NC}"
        return 1
    fi
    
    echo -e "${WHITE}Select service to manage:${NC}"
    echo ""
    echo -e "${GREEN}1. 🔄 Restart Panel${NC}"
    echo -e "${GREEN}2. ⚙️ Restart Daemon${NC}"
    echo -e "${GREEN}3. 🔄 Restart All${NC}"
    echo -e "${YELLOW}4. 📋 View Service Logs${NC}"
    echo -e "${RED}5. ⏹️ Stop All Services${NC}"
    echo -e "${BLUE}6. ↩️ Back to Menu${NC}"
    echo ""
    echo -e "${WHITE}Option: ${NC}"
    read service_choice
    
    case $service_choice in
        1)
            if pm2 list | grep -q "draco-panel"; then
                pm2 restart draco-panel --silent
                echo -e "${GREEN}✅ Panel restarted${NC}"
            else
                echo -e "${RED}❌ Panel is not running${NC}"
            fi
            ;;
        2)
            if pm2 list | grep -q "draco-daemon"; then
                pm2 restart draco-daemon --silent
                echo -e "${GREEN}✅ Daemon restarted${NC}"
            else
                echo -e "${RED}❌ Daemon is not running${NC}"
            fi
            ;;
        3)
            pm2 restart all --silent
            echo -e "${GREEN}✅ All services restarted${NC}"
            ;;
        4)
            echo -e "${YELLOW}📋 Select logs to view:${NC}"
            echo ""
            echo -e "1. 📝 Panel Logs"
            echo -e "2. 📝 Daemon Logs"
            echo -e "3. 📝 All Logs"
            echo ""
            read log_choice
            
            case $log_choice in
                1) pm2 logs draco-panel --lines=50 ;;
                2) pm2 logs draco-daemon --lines=50 ;;
                3) pm2 logs --lines=30 ;;
                *) echo -e "${RED}❌ Invalid option${NC}" ;;
            esac
            ;;
        5)
            pm2 stop all --silent
            echo -e "${GREEN}✅ All services stopped${NC}"
            ;;
        6)
            return
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Función para ver estado del sistema
system_status() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          ${WHITE}📊 SYSTEM STATUS${CYAN}                              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    get_server_ip
    
    # Información del sistema
    echo -e "${WHITE}🌐 System Information:${NC}"
    echo -e "${BLUE}   • Server IP:    $SERVER_IP${NC}"
    echo -e "${BLUE}   • Current Dir:  $INSTALL_DIR${NC}"
    echo -e "${BLUE}   • Default Ports: Panel:$PANEL_PORT, Daemon:$DAEMON_PORT, FTP:$FTP_PORT${NC}"
    echo ""
    
    # Verificar instalaciones
    echo -e "${WHITE}📦 Installed Components:${NC}"
    
    if [ -d "v4panel" ]; then
        echo -e "${GREEN}   ✅ Draco Panel:     Installed in v4panel/${NC}"
    else
        echo -e "${RED}   ❌ Draco Panel:     Not installed${NC}"
    fi
    
    if [ -d "daemon" ]; then
        echo -e "${GREEN}   ✅ Draco Daemon:    Installed in daemon/${NC}"
    else
        echo -e "${RED}   ❌ Draco Daemon:    Not installed${NC}"
    fi
    
    echo ""
    
    # Verificar PM2 y servicios
    if command -v pm2 >/dev/null 2>&1; then
        echo -e "${WHITE}⚡ PM2 Services Status:${NC}"
        echo ""
        
        # Mostrar servicios de Draco
        pm2 list | grep -E "(draco-|App name|┌|├)" | head -20
        
        echo ""
        echo -e "${WHITE}📈 Port Status:${NC}"
        
        # Verificar puertos
        for port_name in "Panel" "Daemon" "FTP"; do
            case $port_name in
                "Panel") port=$PANEL_PORT ;;
                "Daemon") port=$DAEMON_PORT ;;
                "FTP") port=$FTP_PORT ;;
            esac
            
            if check_port $port; then
                echo -e "${RED}   ❌ $port_name port $port: AVAILABLE${NC}"
            else
                echo -e "${GREEN}   ✅ $port_name port $port: IN USE${NC}"
            fi
        done
    else
        echo -e "${YELLOW}⚠️ PM2 is not installed${NC}"
        echo -e "${YELLOW}Services may not be running as daemons${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Función principal
main() {
    # Verificar si estamos en un entorno con sudo
    if [ "$EUID" -eq 0 ]; then
        echo -e "${YELLOW}⚠️ Running as root user${NC}"
    else
        echo -e "${YELLOW}ℹ️ Some commands may require sudo privileges${NC}"
    fi
    
    # Mostrar información inicial
    show_banner
    echo -e "${CYAN}Welcome to Draco Control System Installer${NC}"
    echo -e "${YELLOW}This script will install and configure Draco Panel and Daemon${NC}"
    echo ""
    
    sleep 2
    
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
                configure_daemon
                ;;
            4)
                manage_services
                ;;
            5)
                system_status
                ;;
            6)
                echo ""
                echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo -e "${GREEN}                    Thank you for using Draco Control System                    ${NC}"
                echo -e "${GREEN}                           Powered by Felix Studios                            ${NC}"
                echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Capturar Ctrl+C
trap 'echo -e "\n${YELLOW}👋 Exiting installer...${NC}"; exit 0' INT

# Iniciar
main
