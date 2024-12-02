import random
from db_models.models import db, Building, Room, Space
from app import app

# Lists of building codes and space descriptions
BUILDING_CODES = [
    "AAB", "AB", "ACC", "AEIVA", "ALGEN", "ALUM", "ARCL", "ASC", "BBRB", "BDB",
    "BELL", "BNTH", "BRDGS", "BREM", "BRPB", "BRTW", "BUR", "BZ2H", "CBSE",
    "CCB", "CEC", "CGH", "CH", "CH19", "CH20", "CHB", "CHEM", "CHT", "CIRC", 
    "CLB", "CMPH", "CPM", "CRCT", "CRM", "CRWH", "CSB", "CU", "CU3", "CU5", 
    "CVB", "DAN", "DEW", "DNMH", "EEC", "EFH", "ESH", "EXP4", "FAA1", "FAB", 
    "FLOB", "FOPS", "FPSF", "FTC", "GFED", "GH", "GMOB", "GOLD", "GSB", "HC", 
    "HCSMT", "HGLD", "HGLDPD", "HHB", "HILL", "HLTN", "HMB", "HMOB", "HOEN", 
    "HOH", "HPB", "HRMC", "HSB", "HTA", "IDB", "IMF", "IRF", "IVNS", "JCDH", 
    "JCDHM", "JFSC", "JH", "JNWB", "JT", "KAUL", "KCPD", "LEEDS", "LHFOT", 
    "LHL", "LP", "LRC", "MCC", "MCH", "MCLM", "MCMH", "MEB", "MMT", "MOPS", 
    "MPB", "MRMC", "MSCM", "MT", "MWPOB", "NB", "NHB", "NP", "NW", "OHB", 
    "OHS", "OLB", "OSB", "OSC"
]

SPACE_DESCRIPTIONS = [
    "Shelf A", "Shelf B", "Shelf C", "Table A", "Table B", "Table C",
    "West Wall", "East Wall"
]

def update_database():
    try:
        # Update Building names
        print("Updating Building names...")
        buildings = Building.query.all()
        for building in buildings:
            random_code = random.choice(BUILDING_CODES)
            building.name = random_code
            print(f"Updated Building ID {building.id} to Name {building.name}")

        # Update Space descriptions
        print("Updating Space descriptions...")
        spaces = Space.query.all()
        for space in spaces:
            random_description = random.choice(SPACE_DESCRIPTIONS)
            space.description = random_description
            print(f"Updated Space ID {space.id} to Description {space.description}")

        # Update Room contact phones
        print("Updating Room contact phones...")
        rooms = Room.query.all()
        for room in rooms:
            random_phone = f"205{random.randint(1000000, 9999999)}"
            room.contact_phone = random_phone
            print(f"Updated Room ID {room.id} to Contact Phone {room.contact_phone}")

        # Commit changes to the database
        db.session.commit()
        print("Database updates committed successfully.")
    except Exception as e:
        print(f"An error occurred: {e}")
        db.session.rollback()

if __name__ == "__main__":
    with app.app_context():
        update_database()
