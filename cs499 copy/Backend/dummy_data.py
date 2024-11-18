from faker import Faker
from db_models.models import db, Chemical, PI, User, Building, Room, Space
from app import app  # Assuming your app instance is in app.py

# Initialize Faker
fake = Faker()

# Random chemicals
chemical_names = [
    'Acetone', 'Ethanol', 'Benzene', 'Sulfuric Acid', 'Sodium Hydroxide', 'Hydrogen Peroxide',
    'Methanol', 'Chloroform', 'Toluene', 'Formaldehyde', 'Ammonia', 'Carbon Dioxide',
    'Nitric Acid', 'Phosphoric Acid', 'Potassium Chloride', 'Calcium Carbonate', 'Magnesium Sulfate',
    'Sodium Chloride', 'Acetic Acid', 'Hydrochloric Acid', 'Sodium Bicarbonate', 'Potassium Hydroxide',
    'Ethylene Glycol', 'Glycerol', 'Isopropanol', 'Sodium Sulfate', 'Calcium Hydroxide', 'Hexane',
    'Diethyl Ether', 'Sodium Hypochlorite'
]

# Generate a large number of dummy records
def generate_dummy_data():
    with app.app_context():
        # Create dummy users
        users = []
        for _ in range(10):
            user = User(
                name=fake.name(),
                email=fake.email(),
            )
            user.set_password('password')
            db.session.add(user)
            users.append(user)  # Store users for later association

        # Create dummy PIs and associate them with users
        pis = []
        for _ in range(5):
            pi = PI(
                name=fake.name(),
                email=fake.email(),
            )
            pi.set_password('password')
            db.session.add(pi)
            pis.append(pi)

        # Associate users with random PIs, ensuring no duplicate associations
        for user in users:
            # Get 1 to 3 unique random PIs for the user
            random_pis = fake.random_elements(elements=pis, length=fake.random_int(min=1, max=3), unique=True)
            for pi in random_pis:
                if pi not in user.pis:  # Ensure no duplicate association
                    user.pis.append(pi)

        # Create dummy buildings and rooms
        for _ in range(3):
            building = Building(
                name=fake.company()
            )
            db.session.add(building)
            db.session.flush()  # Ensures the building gets an ID before creating rooms

            for _ in range(2):
                room = Room(
                    building_id=building.id,
                    room_number=fake.building_number(),
                    pi_id=fake.random_element(pis).id,  # Associate with a random PI
                    contact_name=fake.name(),
                    contact_phone=fake.phone_number()
                )
                db.session.add(room)
                db.session.flush()

                # Create dummy spaces
                for _ in range(3):
                    space = Space(
                        room_id=room.id,
                        description=fake.sentence(),
                        space_type=fake.word()
                    )
                    db.session.add(space)
                    db.session.flush()

                    # Create dummy chemicals in the space
                    for _ in range(10):
                        chemical = Chemical(
                            name=fake.random_element(chemical_names),
                            cas_number=fake.ein(),
                            room_id=room.id,
                            space_id=space.id,
                            amount=fake.random_number(digits=3),
                            unit='g',  # Example unit
                            expiration_date=fake.future_date(),
                            total_weight_lbs=fake.random_number(digits=3)
                        )
                        db.session.add(chemical)

        # Commit all the dummy data to the database
        db.session.commit()

if __name__ == '__main__':
    generate_dummy_data()
    print("Dummy data successfully added.")
