import random
from db_models.models import db, Building, Space
from app import app

# Lists of building codes and space types
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

SPACE_TYPES = ["Non-Hazardous", "Radioactive", "Hazardous", "Toxic", "Non-Toxic"]

def update_database():
    try:
        # Add new buildings if they don't exist
        print("Adding new buildings...")
        for code in BUILDING_CODES:
            existing_building = Building.query.filter_by(name=code).first()
            if not existing_building:
                new_building = Building(name=code)
                db.session.add(new_building)
                print(f"Added new Building: {code}")

        # Update Space types
        print("Updating Space types...")
        spaces = Space.query.all()
        for space in spaces:
            random_type = random.choice(SPACE_TYPES)
            space.space_type = random_type
            print(f"Updated Space ID {space.id} to Type {space.space_type}")

        # Commit changes to the database
        db.session.commit()
        print("Database updates committed successfully.")
    except Exception as e:
        print(f"An error occurred: {e}")
        db.session.rollback()

if __name__ == "__main__":
    with app.app_context():
        update_database()